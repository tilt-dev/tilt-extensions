#!/bin/bash
#
# Reconcilation for each uiresource.
#
# Given the name of a UIResource, we check:
# 1) Does it have any localhost links?
# 2) If so, attach an ngrok button that enables/disables the tunnel

set -euo pipefail

name="$1"
echo "reconciling $name"

disabled="true"
ports=()
links="$(tilt get uiresource -o jsonpath='{range .status.endpointLinks[*]}{.url}{"\n"}{end}' -- "$name")"
for link in $links;
do
    host="localhost"
    port="$(echo "$link" | sed -e "s|^http://$host:\([0-9]*\).*|\1|")"
    if [[ "$port" != "$link" ]]; then
        ports+=("$port")
        disabled="false"
    fi
done

child_name="ngrok:$name"
if [[ "$disabled" == "true" ]]; then
    tilt delete uibutton --ignore-not-found -- "$child_name"
    tilt delete configmap --ignore-not-found -- "$child_name"
    tilt delete cmd --ignore-not-found -- "$child_name"
    exit 0
fi

cm_enabled="$(tilt get configmap --ignore-not-found -o jsonpath='{.data.enabled}' -- "$child_name")"
if [[ "$cm_enabled" == "" ]]; then
    cm_enabled="false"
fi

text="start ngrok"
icon_name="play_circle_outline"
if [[ "$cm_enabled" == "true" ]]; then
    text="stop ngrok"
    icon_name="stop_circle"
fi

dir=$(realpath "$(dirname "$0")")
cat <<EOF | tilt apply -f -
apiVersion: tilt.dev/v1alpha1
kind: UIButton
metadata:
  name: "$child_name"
  annotations:
    tilt.dev/resource: "$name"
    tilt.dev/log-span-id: "$child_name"
  labels:
    tilt.dev/managed-by: tilt-extensions.ngrok
spec:
  text: "$text"
  iconName: "$icon_name"
  location:
    componentType: resource
    componentID: $name
---
apiVersion: tilt.dev/v1alpha1
kind: Cmd
metadata:
  name: "$child_name"
  annotations:
    tilt.dev/resource: "$name"
    tilt.dev/log-span-id: "$child_name"
  labels:
    tilt.dev/managed-by: tilt-extensions.ngrok
spec:
  args: ["./toggle-ngrok.sh", "$name"]
  dir: "$dir"
  startOn:
    uiButtons:
    - "$child_name"
---
apiVersion: tilt.dev/v1alpha1
kind: ConfigMap
metadata:
  name: "$child_name"
  labels:
    tilt.dev/managed-by: tilt-extensions.ngrok
data:
  ports: "${ports[@]}"
  resource: "$name"
  enabled: "$cm_enabled"
EOF
