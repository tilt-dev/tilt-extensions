#!/bin/bash
#
# Continuously watch the namespaces that we're deploying to, and sync them.

set -euo pipefail

# Legacy mode: file-based trigger
if [[ "${TILT_KUBEFWD_MODE:-idle}" == "legacy" ]]; then
    function reconcile_legacy {
        NEW_NAMESPACES=$(tilt get kd -o=jsonpath='{.items[*].spec.watches[*].namespace}' 2>/dev/null || true)
        NEW_NAMESPACES=$(echo "$NEW_NAMESPACES ${TILT_CFG_NAMESPACES:-}" | tr -s ' ' '\n' | sort -u)
        OLD_NAMESPACES=$(cat "$TILT_KUBEFWD_TRIGGER" 2>/dev/null || true)
        if [[ "$NEW_NAMESPACES" != "$OLD_NAMESPACES" ]]; then
            echo "$NEW_NAMESPACES" > "$TILT_KUBEFWD_TRIGGER"
        fi
    }

    reconcile_legacy
    tilt get kd --watch -o name | while read -r; do
        reconcile_legacy
    done
    exit 0
fi

# Idle mode: API-based sync
# Wait for kubefwd API to become healthy
until curl -s -f -o /dev/null "http://kubefwd.internal/api/health"; do
    sleep 1
done

function get_api_namespaces {
    curl -s http://kubefwd.internal/api/v1/namespaces | \
        jq -r '.data.namespaces[]?.namespace // empty' | \
        sort -u
}

function reconcile {
    NEW_NAMESPACES=$(tilt get kd -o=jsonpath='{.items[*].spec.watches[*].namespace}' | echo "$(cat -) $TILT_CFG_NAMESPACES" | tr -s ' ' '\n' | sort -u)

    # In kubefwd, we need to add missing namespaces and remove extra ones
    ACTIVE_NAMESPACES=$(get_api_namespaces)

    for ns in $NEW_NAMESPACES; do
        if [[ "$ns" == "" ]]; then continue; fi
        if ! echo "$ACTIVE_NAMESPACES" | grep -q "^${ns}$"; then
            echo "Adding namespace to kubefwd: $ns"
            curl -s -X POST "http://kubefwd.internal/api/v1/namespaces" \
                 -H "Content-Type: application/json" \
                 -d "{\"namespace\": \"$ns\"}" >/dev/null || true
        fi
    done

    for ns in $ACTIVE_NAMESPACES; do
        if [[ "$ns" == "" ]]; then continue; fi
        if ! echo "$NEW_NAMESPACES" | grep -q "^${ns}$"; then
            echo "Removing namespace from kubefwd: $ns"
            # Get the exact key for this namespace to delete it
            KEY=$(curl -s http://kubefwd.internal/api/v1/namespaces | \
                  jq -r --arg ns "$ns" '.data.namespaces[]? | select(.namespace == $ns) | .key // empty')
            if [[ "$KEY" != "" ]]; then
                curl -s -X DELETE "http://kubefwd.internal/api/v1/namespaces/$KEY" >/dev/null || true
            fi
        fi
    done
}

reconcile

tilt get kd --watch -o name | while read -r; do
    reconcile
done
