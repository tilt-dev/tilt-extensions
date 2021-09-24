#!/bin/bash

set -euo pipefail

TRIGGER="$1"

cat <<EOF | tilt apply -f -
apiVersion: tilt.dev/v1alpha1
kind: UIButton
metadata:
  name: kubefwd:refresh
spec:
  text: Refresh
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
  args: ["touch", "$TRIGGER"]
  startOn:
    uiButtons:
    - kubefwd:refresh
EOF
