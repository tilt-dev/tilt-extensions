#!/usr/bin/env bash

set -euo pipefail

if [[ "${TILT_KUBEFWD_MODE:-idle}" == "legacy" ]]; then
    BTN_ARGS="[\"touch\", \"${TILT_KUBEFWD_TRIGGER}\"]"
else
    BTN_ARGS="[\"curl\", \"-s\", \"-X\", \"POST\", \"-H\", \"Authorization: Bearer ${KUBEFWD_API_KEY}\", \"http://kubefwd.internal/api/v1/services/reconnect?force=true\"]"
fi

cat <<EOF | tilt apply -f -
apiVersion: tilt.dev/v1alpha1
kind: UIButton
metadata:
  name: kubefwd:refresh
spec:
  text: Refresh
  iconName: refresh
  location:
    componentType: resource
    componentID: kubefwd:run
---
apiVersion: tilt.dev/v1alpha1
kind: Cmd
metadata:
  name: kubefwd:refresh
  annotations:
    "tilt.dev/resource": "kubefwd:run"
spec:
  args: ${BTN_ARGS}
  startOn:
    uiButtons:
    - kubefwd:refresh
EOF
