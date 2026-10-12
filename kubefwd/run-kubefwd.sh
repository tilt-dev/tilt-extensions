#!/usr/bin/env bash
# Run kubefwd, assuming we already have sudo privs.

export KUBEFWD="$1"
export KUBECONFIG="$2"
export ENTR="$3"
export TILT_KUBEFWD_MODE="$4"
export TILT_KUBEFWD_TRIGGER="$5"
export KUBEFWD_PURGE="$6"
export KUBEFWD_API_KEY="$7"

DIR=$(realpath "$(dirname "$0")")

set -exuo pipefail

if [[ "$TILT_KUBEFWD_MODE" == "legacy" ]]; then
    echo "$TILT_KUBEFWD_TRIGGER" | "$ENTR" -rn "$DIR/run-kubefwd-internal.sh"
else
    flags=()
    if [[ "${KUBEFWD_PURGE:-false}" == "true" ]]; then
        flags+=("--purge-stale-ips")
    fi

    # Kill any lingering kubefwd processes from previous Tilt runs
    # and wait for them to exit to prevent race conditions with /etc/hosts
    (pkill -x kubefwd && pidwait -x kubefwd) || true

    # Check array length before expanding to avoid unbound variable errors
    # in Bash 3.2 (macOS default) when 'set -u' is enabled and the array is empty.

    echo "API Key: ${KUBEFWD_API_KEY}"

    if [ ${#flags[@]} -eq 0 ]; then
        exec "$KUBEFWD"
    else
        exec "$KUBEFWD" "${flags[@]}"
    fi
fi
