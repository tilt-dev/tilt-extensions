#!/bin/bash
# Run kubefwd, assuming we already have sudo privs.

set -exuo pipefail

KUBEFWD="$1"
export KUBECONFIG="$2"

"$KUBEFWD" svc -n default
