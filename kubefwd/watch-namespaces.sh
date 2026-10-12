#!/usr/bin/env bash
#
# Continuously watch the namespaces that we're deploying to, and sync them.

set -euo pipefail

trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

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

CURL_OPTS=("-s" "-f")
if [[ -n "${KUBEFWD_API_KEY:-}" ]]; then
    CURL_OPTS+=("-H" "Authorization: Bearer ${KUBEFWD_API_KEY}")
fi

# Wait for kubefwd API to become healthy
until curl "${CURL_OPTS[@]}" -o /dev/null "http://kubefwd.internal/api/health"; do
    sleep 1
done

function get_api_namespaces {
    local resp
    if ! resp=$(curl "${CURL_OPTS[@]}" http://kubefwd.internal/api/v1/namespaces); then
        return 1
    fi
    echo "$resp" | jq -r '.data.namespaces[]?.namespace // empty' | sort -u
}

function reconcile {
    NEW_NAMESPACES=$(tilt get kd -o=jsonpath='{.items[*].spec.watches[*].namespace}' 2>/dev/null || true)
    NEW_NAMESPACES=$(echo "$NEW_NAMESPACES ${TILT_CFG_NAMESPACES:-}" | tr -s ' ' '\n' | sort -u)

    # In kubefwd, we need to add missing namespaces and remove extra ones
    local ACTIVE_NAMESPACES
    if ! ACTIVE_NAMESPACES=$(get_api_namespaces); then
        # API is not healthy/reachable right now. Wait for the next tick.
        return 0
    fi

    for ns in $NEW_NAMESPACES; do
        if [[ "$ns" == "" ]]; then continue; fi
        if ! echo "$ACTIVE_NAMESPACES" | grep -q "^${ns}$"; then
            echo "Adding namespace to kubefwd: $ns"
            curl -s -X POST -H "Authorization: Bearer ${KUBEFWD_API_KEY:-}" \
                 -H "Content-Type: application/json" \
                 -d "{\"namespace\": \"$ns\"}" "http://kubefwd.internal/api/v1/namespaces" >/dev/null || true
        fi
    done

    for ns in $ACTIVE_NAMESPACES; do
        if [[ "$ns" == "" ]]; then continue; fi
        if ! echo "$NEW_NAMESPACES" | grep -q "^${ns}$"; then
            echo "Removing namespace from kubefwd: $ns"
            # Get the exact key for this namespace to delete it
            KEY=$(curl "${CURL_OPTS[@]}" http://kubefwd.internal/api/v1/namespaces | \
                  jq -r --arg ns "$ns" '.data.namespaces[]? | select(.namespace == $ns) | .key // empty' || true)
            if [[ "$KEY" != "" ]]; then
                curl -s -X DELETE -H "Authorization: Bearer ${KUBEFWD_API_KEY:-}" "http://kubefwd.internal/api/v1/namespaces/$KEY" >/dev/null || true
            fi
        fi
    done
}

reconcile

{
    tilt get kd --watch -o name &
    while true; do sleep 5; echo "tick"; done
} | while read -r; do
    reconcile
done
