#!/bin/bash
#
# toggle-ngrok.sh
#
# Flips the enabled field on the configmap, and updates
# the button text to reflect the new state.

set -euo pipefail

name="$1"
child_name="ngrok:$name"
cm="$(tilt get configmap -o json -- "$child_name")"
enabled="$(echo "$cm" | jq -r ".data.enabled")"
new_val="true"
new_text="stop ngrok"
new_icon="stop_circle"
if [[ "$enabled" == "true" ]]; then
    new_val="false"
    new_text="start ngrok"
    new_icon="play_circle_outline"
fi

tilt patch uibutton -p "{\"spec\":{\"text\":\"$new_text\", \"iconName\":\"$new_icon\"}}" -- "$child_name"
tilt patch configmap -p "{\"data\":{\"enabled\":\"$new_val\"}}" -- "$child_name"

if [[ "$enabled" != "true" ]]; then
    echo "ngrok tunnel started"
    
    # This is a bit racy, but should work well enough for now.
    sleep 2

    echo "Current ngrok tunnels:"
    curl -sSL http://localhost:4040/api/tunnels | jq -r ".tunnels[] | .name, .public_url"
else
    echo "ngrok tunnel stopped"
fi
