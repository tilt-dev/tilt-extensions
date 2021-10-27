#!/bin/bash

# Adapted from Karl Bunch's post on Server Fault:
# https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod/887402#887402

set -e

# make sure local tmp dir exists (see -T= argument in Tiltfile)
mkdir -p /tmp/rsync.tilt

rsync_tilt_path=/bin/rsync.tilt

install_rsync_tilt() {
    if [ -z "$RSYNC_PATH" ]; then
        # rsync already checked/installed
        return 0
    fi

    local tar_path_local=${0%/*}/rsync.tilt.tar  # TODO: option for windows binary
    # ensure our rsync bin is present on container in the expected location
    set +e # disable exit on error
    kubectl exec "$K8S_OBJECT" -- ls "$rsync_tilt_path" > /dev/null 2>&1
    exit_code="$?"
    set -e
    if [[ "$exit_code" != "0" ]]; then
        # shellcheck disable=SC2002
        cat "$tar_path_local" | kubectl exec -i "$K8S_OBJECT" -- tar -xf - -C $(dirname $rsync_tilt_path)
    fi
}

find_rsync_path() {
    local rsync_path=--rsync-path=$rsync_tilt_path
    # see if we already have a compatible rsync on the container
    local rsync_version=$(kubectl exec "$K8S_OBJECT" -- rsync --version 2> /dev/null \
                              | head -1 | awk '{ print $3 }')
    if [ "$rsync_version" ] && [[ "$rsync_version" > 3 ]]; then
        rsync_path=
    fi
    echo $rsync_path
}

if [ -z "$KRSYNC_STARTED" ]; then
  export K8S_OBJECT="$1"
  shift
  export KRSYNC_STARTED=true
  export RSYNC_PATH=$(find_rsync_path)
  exec rsync $RSYNC_PATH --blocking-io --rsh "$0" "$@"
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

exec kubectl exec -i "$K8S_OBJECT" -- "$@"
