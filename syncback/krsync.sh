#!/bin/bash

# Adapted from Karl Bunch's post on Server Fault:
# https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod/887402#887402

set -e

# make sure local tmp dir exists (see -T= argument in Tiltfile)
mkdir -p /tmp/rsync.tilt
mkdir -p /tmp/rsync.tilt.krsync

rsync_tilt_path=/bin/rsync.tilt

krsync_path="/tmp/rsync.tilt.krsync/krsync.sh" 
if [ "$0" != "$krsync_path" ]; then
    cp "$0" "$krsync_path"
fi

install_rsync_tilt() {
    if [ -z "$RSYNC_PATH" ]; then
        # rsync already checked/installed
        return 0
    fi

    # ensure our rsync bin is present on container in the expected location
    set +e # disable exit on error
    # $K8S_OBJECT is intentionally not quoted here so -n/-c flags can be
    # parsed by kubectl
    kubectl exec $K8S_OBJECT -- ls "$rsync_tilt_path" > /dev/null 2>&1
    exit_code="$?"
    set -e
    if [[ "$exit_code" != "0" ]]; then
        # shellcheck disable=SC2002
        cat "$KRSYNC_TAR_PATH" | kubectl exec -i $K8S_OBJECT -- tar -xf - -C $(dirname $rsync_tilt_path)
    fi
}

find_rsync_path() {
    local rsync_path=--rsync-path=$rsync_tilt_path
    # ensure pipeline status is non-zero if rsync is missing in the container
    set -o pipefail
    # see if we already have a compatible rsync on the container
    detected_rsync_version=$(kubectl exec $K8S_OBJECT -- rsync --version 2> /dev/null \
                              | head -1 | awk '{ print $3 }')
    if [ $? -eq 0 -a "$detected_rsync_version" ] && [[ "$detected_rsync_version" > 3 ]]; then
        rsync_path=
    fi
    echo $rsync_path
}

if [ -z "$KRSYNC_STARTED" ]; then
    # Quote/set to the entire first argument, which could contain
    # '-n namespace'/'-c container' flags
    export K8S_OBJECT="$1"
    export KRSYNC_TAR_PATH="${0%/*}/rsync.tilt.tar"
    shift
    export KRSYNC_STARTED=true
    export RSYNC_PATH=$(find_rsync_path)
    exec rsync $RSYNC_PATH --blocking-io --rsh "$krsync_path" "$@"
fi

## Shift away server and possible username arguments
# Running as --rsh
depl=$1
shift

# If user uses depl@namespace rsync passes as: {us} -l depl namespace ...
if [ "X$depl" = "X-l" ]; then
    depl=$1
    shift
    shift
fi

install_rsync_tilt

# $K8S_OBJECT is intentionally not quoted here, see above
exec kubectl exec -i $K8S_OBJECT -- "$@"
