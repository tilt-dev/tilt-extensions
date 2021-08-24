#!/bin/bash
#
# Continuously watch the namespaces that we're deploying to, and write them to
# the trigger file.

TRIGGER="$1"

tilt get kd --watch -o name | while read -r; do
    NEW_NAMESPACES=$(tilt get kd -o=jsonpath='{.items[*].spec.watches[*].namespace}' | tr -s ' ' '\n' | sort -u)
    OLD_NAMESPACES=$(cat "$TRIGGER")
    if [[ "$NEW_NAMESPACES" != "$OLD_NAMESPACES" ]]; then
        echo "$NEW_NAMESPACES" > "$TRIGGER"
    fi
done
