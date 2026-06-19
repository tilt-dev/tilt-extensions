#!/usr/bin/env bash
#
# Runs kubefwd with admin privileges.
# Invokes an OS-specific sudo UI.

ENTR=$(command -v entr)
OSASCRIPT=$(command -v osascript)
PKEXEC=$(command -v pkexec)
SUDO=$(command -v sudo)
KDESUDO=$(command -v kdesudo)
GKSUDO=$(command -v gksudo)
KUBEFWD=$(command -v kubefwd)
JQ=$(command -v jq)
DIR=$(realpath "$(dirname "$0")")
KUBECONFIG=${KUBECONFIG:-${HOME}/.kube/config}
TILT_KUBEFWD_MODE=${TILT_KUBEFWD_MODE:-idle}
TILT_KUBEFWD_TRIGGER=${TILT_KUBEFWD_TRIGGER:-}
KUBEFWD_PURGE=${KUBEFWD_PURGE:-false}

set -euo pipefail

# Check to make sure all the necessary deps are installed.
if [[ "$KUBEFWD" == "" ]]; then
    echo "kubefwd not found. Did you forget to install it?"
    echo "Run: brew install txn2/tap/kubefwd"
    exit 1
fi

if [[ "$TILT_KUBEFWD_MODE" == "legacy" ]]; then
    if [[ "$ENTR" == "" ]]; then
        echo "entr not found. Did you forget to install it?"
        echo "Run: brew install entr"
        exit 1
    fi
else
    if [[ "$JQ" == "" ]]; then
        echo "jq not found. Did you forget to install it?"
        echo "Run: brew install jq"
        exit 1
    fi
fi

# Copy kubefwd script into a new directory to avoid path normalization issues.
mkdir -p /tmp/kubefwd.tilt

run_kubefwd_path="/tmp/kubefwd.tilt/run-kubefwd.sh"
cp "$(dirname "$0")/run-kubefwd.sh" $run_kubefwd_path

RUN_KUBEFWD=$run_kubefwd_path

if [[ "$TILT_KUBEFWD_MODE" == "legacy" ]]; then
    run_kubefwd_internal_path="/tmp/kubefwd.tilt/run-kubefwd-internal.sh"
    cp "$(dirname "$0")/run-kubefwd-internal.sh" $run_kubefwd_internal_path

    # Initialize the trigger file
    touch "$TILT_KUBEFWD_TRIGGER"
    chmod a+rw "$TILT_KUBEFWD_TRIGGER"
fi

# In the background, synchronize the namespaces we need to watch.
"$DIR/watch-namespaces.sh" &
WATCH_PID="$!"

# shellcheck disable=SC2317
function cleanup {
    set -x
    set +e

    if [[ "$TILT_KUBEFWD_MODE" == "legacy" ]]; then
        rm -f "$TILT_KUBEFWD_TRIGGER"
    fi

    kill "$WATCH_PID"
    wait "$WATCH_PID"

    if [[ "$TILT_KUBEFWD_MODE" == "legacy" ]]; then
        rm -f "$TILT_KUBEFWD_TRIGGER"
    fi
}
trap cleanup EXIT

if [[ "${TILT_SUDO_NON_INTERACTIVE:-false}" == "true" ]] && [[ "$SUDO" != "" ]]; then
    set -x
    "$SUDO" -n "$RUN_KUBEFWD" "$KUBEFWD" "$KUBECONFIG" "$ENTR" "$TILT_KUBEFWD_MODE" "$TILT_KUBEFWD_TRIGGER" "$KUBEFWD_PURGE"
    exit "$?"
fi

if [[ "$OSASCRIPT" != "" ]]; then
    set -x
    CMD="'$RUN_KUBEFWD' '$KUBEFWD' '$KUBECONFIG' '$ENTR' '$TILT_KUBEFWD_MODE' '$TILT_KUBEFWD_TRIGGER' '$KUBEFWD_PURGE'"
    "$OSASCRIPT" -e "do shell script \"$CMD\" with administrator privileges"
    exit "$?"
fi

if [[ "$PKEXEC" != "" ]]; then
    set -x
    "$PKEXEC" --disable-internal-agent "$RUN_KUBEFWD" "$KUBEFWD" "$KUBECONFIG" "$ENTR" "$TILT_KUBEFWD_MODE" "$TILT_KUBEFWD_TRIGGER" "$KUBEFWD_PURGE"
    exit "$?"
fi

if [[ "$KDESUDO" != "" ]]; then
    set -x
    "$KDESUDO" --comment 'Tilt needs admin privs to run kubefwd. Please enter your password.' "$RUN_KUBEFWD" "$KUBEFWD" "$KUBECONFIG" "$ENTR" "$TILT_KUBEFWD_MODE" "$TILT_KUBEFWD_TRIGGER" "$KUBEFWD_PURGE"
    exit "$?"
fi

if [[ "$GKSUDO" != "" ]]; then
    set -x
    "$GKSUDO" --preserve-env --sudo-mode --description 'tilt/kubefwd' "$RUN_KUBEFWD" "$KUBEFWD" "$KUBECONFIG" "$ENTR" "$TILT_KUBEFWD_MODE" "$TILT_KUBEFWD_TRIGGER" "$KUBEFWD_PURGE"
    exit "$?"
fi

echo "No sudo runner found"
exit 1
