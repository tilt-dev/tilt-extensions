#!/bin/bash
#
# Continuously watch the namespaces that we're deploying to, and write them to
# the trigger file.

TRIGGER_FILE="$1"

function reconcile {
    NEW_NAMESPACES=$(tilt get kd -o=jsonpath='{.items[*].spec.watches[*].namespace}' | echo "$(cat -) $TILT_CFG_NAMESPACES" | tr -s ' ' '\n' | sort -u)
    OLD_NAMESPACES=$(cat "$TRIGGER_FILE")
    if [[ "$NEW_NAMESPACES" != "$OLD_NAMESPACES" ]]; then
        echo "$NEW_NAMESPACES" > "$TRIGGER_FILE"
    fi
}

reconcile

tilt get kd --watch -o name | while read -r; do
    reconcile
done
