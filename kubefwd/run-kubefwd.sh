#!/bin/bash
# Run kubefwd, assuming we already have sudo privs.

export KUBEFWD="$1"
export KUBECONFIG="$2"
export ENTR="$3"
export TILT_KUBEFWD_MODE="$4"
export TILT_KUBEFWD_TRIGGER="$5"

DIR=$(realpath "$(dirname "$0")")

set -exuo pipefail

if [[ "$TILT_KUBEFWD_MODE" == "legacy" ]]; then
    echo "$TILT_KUBEFWD_TRIGGER" | "$ENTR" -rn "$DIR/run-kubefwd-internal.sh"
else
    # Kill any lingering kubefwd processes from previous Tilt runs
    pkill -x kubefwd || true

    exec "$KUBEFWD"
fi
