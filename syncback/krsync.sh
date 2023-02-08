#!/bin/bash

# Adapted from Karl Bunch's post on Server Fault:
# https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod/887402#887402

set -e

if [ "$CI" != "" ]; then
    # Print syncback output on CI to make it easier
    # to diagnose failures.
    set -x
fi

# make sure local tmp dir exists (see -T= argument in Tiltfile)
mkdir -p /tmp/rsync.tilt
mkdir -p /tmp/rsync.tilt.krsync

krsync_callback_path="/tmp/rsync.tilt.krsync/krsync-callback.sh" 
cp "$(dirname "$0")/krsync-callback.sh" "$krsync_callback_path"

install_rsync_tilt() {
    if [ -z "$RSYNC_PATH" ]; then
        # rsync already checked/installed
        return 0
    fi

    # ensure our rsync bin is present on container in the expected location
    set +e # disable exit on error
    # $K8S_OBJECT is intentionally not quoted here so -n/-c flags can be
    # parsed by kubectl
    kubectl exec $K8S_OBJECT -- ls "$RSYNC_TILT_PATH" > /dev/null 2>&1
    exit_code="$?"
    set -e
    if [[ "$exit_code" != "0" ]]; then
        # shellcheck disable=SC2002
        echo "installing tilt's rsync"
        cat "$KRSYNC_TAR_PATH" | kubectl exec -i $K8S_OBJECT -- tar -xf - -C $(dirname $RSYNC_TILT_PATH)
    fi
}

find_rsync_path() {
    local rsync_path=--rsync-path=$RSYNC_TILT_PATH
    # see if we already have a compatible rsync on the container
    rsync_output=$(kubectl exec $K8S_OBJECT -- rsync --version 2> /dev/null)
    if [ $? -eq 0 ]; then
        detected_rsync_version=$(echo "$rsync_output" | head -1 | awk '{ print $3 }')
        if [[ "$detected_rsync_version" > 3 ]]; then
            rsync_path=
        fi
    fi
    echo $rsync_path
}

# Quote/set to the entire first argument, which could contain
# '-n namespace'/'-c container' flags
export K8S_OBJECT="$1"
export RSYNC_TILT_PATH="$2"
export KRSYNC_TAR_PATH="${0%/*}/rsync.tilt.tar"
shift
shift
export RSYNC_PATH=$(find_rsync_path)
install_rsync_tilt
exec rsync $RSYNC_PATH --blocking-io --rsh "$krsync_callback_path" "$@"