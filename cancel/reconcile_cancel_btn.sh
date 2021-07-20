#!/bin/bash
#
# Reconcilation for a cancel button.
#
# Given the name of a Cmd object, we check:
# 1) Does this need a cancel button attached?
# 2) If so, attach a cancel button now with the correct PID.
# 3) If not, delete the old cancel button.

set -euo pipefail

cmd_name="$1"
echo "reconciling $cmd_name"

cancel_cmd_name="$cmd_name:cancel"
cancel_button_name="$cmd_name:cancel"
cmd=$(tilt get cmd "$cmd_name" -o json --ignore-not-found)

function delete_children {
    tilt delete cmd "$cancel_cmd_name" --ignore-not-found
    tilt delete uibutton "$cancel_button_name" --ignore-not-found
    exit 0
}

if [[ "$cmd" == "" ]]; then
    delete_children
fi

# Ignore commands that don't belong to a resource.
resource=$(echo "$cmd" | jq -r '.metadata.annotations["tilt.dev/resource"]')
if [[ "$resource" == "null" ]]; then
    exit 0
fi

# Ignore cmds that don't to the Tiltfile or a local_resource.
owner_kind=$(echo "$cmd" | jq -r '.metadata.labels["tilt.dev/owner-kind"]')
echo "kind 1 $owner_kind"
if [[ "$owner_kind" == "null" ]]; then
    # gahhhhh
    owner_kind=$(echo "$cmd" | jq -r '.metadata.annotations["tilt.dev/owner-kind"]')
    echo "kind 2 $owner_kind"
fi
if [[ "$owner_kind" != "Tiltfile" && "$owner_kind" != "CmdServer" ]]; then
    exit 0
fi

# If the command isn't running or doesn't exist, delete any existing button.
pid=$(echo "$cmd" | jq -r '.status.running.pid')
if [[ "$pid" == "" || "$pid" == "null" ]]; then
    delete_children
fi

# TODO(nick): Add Icons to the buttons
dir=$(realpath $(dirname "$0"))
cat <<EOF | tilt apply -f -
apiVersion: tilt.dev/v1alpha1
kind: UIButton
metadata:
  name: $cancel_button_name
spec:
  text: Cancel
  location:
    componentType: resource
    componentID: $resource
---
apiVersion: tilt.dev/v1alpha1
kind: Cmd
metadata:
  name: $cancel_cmd_name
  annotations:
    "tilt.dev/resource": "$resource"
    "tilt.dev/log-span-id": "$cancel_cmd_name"
spec:
  args: ["./kill_cmd.sh", "$cmd_name"]
  dir: $dir
  startOn:
    uiButtons:
    - $cancel_button_name
EOF
