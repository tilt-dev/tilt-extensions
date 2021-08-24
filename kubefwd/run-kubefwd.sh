#!/bin/bash
# Run kubefwd, assuming we already have sudo privs.

export KUBEFWD="$1"
export KUBECONFIG="$2"
export ENTR="$3"
export TRIGGER="$4"

DIR=$(realpath "$(dirname "$0")")

set -exuo pipefail

echo "$TRIGGER" | "$ENTR" -rn "$DIR/run-kubefwd-internal.sh"
