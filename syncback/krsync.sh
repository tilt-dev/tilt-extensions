#!/bin/bash

# Adapted from Karl Bunch's post on Server Fault:
# https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod/887402#887402

set -e

# make sure local tmp dir exists
mkdir -p /tmp/rsync.tilt

rsync_path=/bin/rsync.tilt
tar_path_local=${0%/*}/rsync.tilt.tar  # TODO: option for windows binary

if [ -z "$KRSYNC_STARTED" ]; then
  export K8S_OBJECT=$1
  shift
  export KRSYNC_STARTED=true
  exec rsync --rsync-path=$rsync_path --blocking-io --rsh "$0" $@
fi

# Running as --rsh
namespace=''
depl=$1
shift

# If user uses depl@namespace rsync passes as: {us} -l depl namespace ...
if [ "X$depl" = "X-l" ]; then
    depl=$1
    shift
    namespace="-n $1"
    shift
fi

# ensure our rsync bin is present on container in the expected location
set +e # disable exit on error
kubectl exec $K8S_OBJECT -- ls $rsync_path > /dev/null 2>&1
exit_code="$?"
set -e
if [[ "$exit_code" != "0" ]]; then
  cat $tar_path_local | kubectl $namespace exec -i $K8S_OBJECT -- tar -xf - -C /bin/
fi

exec kubectl $namespace exec -i $K8S_OBJECT -- "$@"

