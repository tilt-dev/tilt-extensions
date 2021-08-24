#!/bin/bash
# Run kubefwd, assuming we already have sudo privs.

KUBEFWD="$1"
export KUBECONFIG="$2"
ENTR="$3"
TRIGGER="$4"

set -exuo pipefail

echo "$TRIGGER" | "$ENTR" -rn "$KUBEFWD" svc -n default
