#!/bin/bash
#
# ngrok-operator.sh
#
# Watches Tilt's UIResources, and creates buttons to enable ngrok for every
# resource with an endpoint link.

config_file="$1"

function reconcile_uiresource() {
    tilt get uiresource --watch -o name | while read -r name; do
        short=${name#uiresource.tilt.dev/}
        ./ngrok-reconcile-uiresource.sh "$short"
    done
}

function reconcile_config() {
    tilt get configmap --watch -o name | while read -r name; do
        ./ngrok-reconcile-config.sh "$config_file"
    done
}

UIRESOURCE_PID=""
function cleanup {
    kill "$UIRESOURCE_PID"
}
trap cleanup EXIT

reconcile_uiresource &
UIRESOURCE_PID="$!"
reconcile_config
