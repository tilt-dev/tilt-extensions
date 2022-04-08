#!/bin/bash
#
# Runs kubefwd with admin privileges.
# Invokes an OS-specific sudo UI.

TRIGGER="$1"
ENTR=$(command -v entr)
OSASCRIPT=$(command -v osascript)
PKEXEC=$(command -v pkexec)
KDESUDO=$(command -v kdesudo)
GKSUDO=$(command -v gksudo)
KUBEFWD=$(command -v kubefwd)
DIR=$(realpath "$(dirname "$0")")
KUBECONFIG=${KUBECONFIG:-${HOME}/.kube/config}

set -euo pipefail

# Check to make sure all the necessary deps are installed.
if [[ "$KUBEFWD" == "" ]]; then
    echo "kubefwd not found. Did you forget to install it?"
    echo "Run: brew install txn2/tap/kubefwd"
    exit 1
fi

if [[ "$ENTR" == "" ]]; then
    echo "entr not found. Did you forget to install it?"
    echo "Run: brew install entr"
    exit 1
fi

# Copy kubefwd script into a new directory to avoid path normalization issues.
mkdir -p /tmp/kubefwd.tilt

run_kubefwd_path="/tmp/kubefwd.tilt/run-kubefwd.sh"
cp "$(dirname "$0")/run-kubefwd.sh" $run_kubefwd_path

run_kubefwd_internal_path="/tmp/kubefwd.tilt/run-kubefwd-internal.sh"
cp "$(dirname "$0")/run-kubefwd-internal.sh" $run_kubefwd_internal_path

RUN_KUBEFWD=$run_kubefwd_path

# Initialize the trigger file
touch "$TRIGGER"
chmod a+rw "$TRIGGER"

# In the background, populate the trigger file
# with the namespaces we need to watch.
"$DIR/watch-namespaces.sh" "$TRIGGER" &
WATCH_PID="$!"

function cleanup {
    set -x
    set +e

    # Remove the trigger file. This will make any dangling entr/kubefwd
    # processes exit. (We can't kill them directly b/c they're running with sudo
    # privs.)
    rm -f "$TRIGGER"
    
    kill "$WATCH_PID"
    wait "$WATCH_PID"

    # Remove the trigger file twice, in case the watcher created a new one.
    rm -f "$TRIGGER"
}
trap cleanup EXIT

if [[ "$OSASCRIPT" != "" ]]; then
    set -x
    "$OSASCRIPT" -e "do shell script \"$RUN_KUBEFWD $KUBEFWD $KUBECONFIG $ENTR $TRIGGER\" with administrator privileges"
    exit "$?"
fi

if [[ "$PKEXEC" != "" ]]; then
    set -x
    "$PKEXEC" --disable-internal-agent "$RUN_KUBEFWD" "$KUBEFWD" "$KUBECONFIG" "$ENTR" "$TRIGGER"
    exit "$?"
fi 

if [[ "$KDESUDO" != "" ]]; then
    set -x
    "$KDESUDO" --comment 'Tilt needs admin privs to run kubefwd. Please enter your password.' "$RUN_KUBEFWD" "$KUBEFWD"  "$KUBECONFIG" "$ENTR" "$TRIGGER"
    exit "$?"
fi 

if [[ "$GKSUDO" != "" ]]; then
    set -x
    "$GKSUDO" --preserve-env --sudo-mode --description 'tilt/kubefwd' "$RUN_KUBEFWD" "$KUBEFWD" "$KUBECONFIG" "$ENTR" "$TRIGGER"
    exit "$?"
fi 

echo "No sudo runner found"
exit 1



