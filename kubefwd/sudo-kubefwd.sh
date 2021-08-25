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
RUN_KUBEFWD=$(pwd)/run-kubefwd.sh
KUBECONFIG=${KUBECONFIG:-${HOME}/.kube/config}

set -euo pipefail

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



