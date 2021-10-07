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
cmd=$(tilt get cmd -o json --ignore-not-found -- "$cmd_name")

function delete_children {
    tilt delete cmd --ignore-not-found -- "$cancel_cmd_name"
    tilt delete uibutton --ignore-not-found -- "$cancel_button_name"
    exit 0
}

# Check if the object has been deleted.
name_in_json=$(echo "$cmd" | jq -r '.metadata.name')
if [[ "$cmd" == "" || "$name_in_json" == "null" ]]; then
    delete_children
fi

# Ignore commands that don't belong to a resource.
resource=$(echo "$cmd" | jq -r '.metadata.annotations["tilt.dev/resource"]')
if [[ "$resource" == "null" ]]; then
    exit 0
fi

# Ignore cmds that don't belong to the Tiltfile or a local_resource.
owner_kind=$(echo "$cmd" | jq -r '.metadata.labels["tilt.dev/owner-kind"]')
if [[ "$owner_kind" == "null" ]]; then
    owner_kind=$(echo "$cmd" | jq -r '.metadata.annotations["tilt.dev/owner-kind"]')
fi
if [[ "$owner_kind" == "null" ]]; then
    owner_kind=$(echo "$cmd" | jq -r '.metadata.ownerReferences[0]["kind"]')
fi
if [[ "$owner_kind" != "Tiltfile" && "$owner_kind" != "CmdServer" ]]; then
    exit 0
fi

# If the command isn't running or doesn't exist, disable the button
pid=$(echo "$cmd" | jq -r '.status.running.pid')
disabled="false"
if [[ "$pid" == "" || "$pid" == "null" ]]; then
    disabled="true"
fi

# TODO(nick): Add Icons to the buttons
dir=$(realpath "$(dirname "$0")")
cat <<EOF | tilt apply -f -
apiVersion: tilt.dev/v1alpha1
kind: UIButton
metadata:
  name: $cancel_button_name
spec:
  disabled: $disabled
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
