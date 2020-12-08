#!/bin/bash

# Adapted from Karl Bunch's post on Server Fault:
# https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod/887402#887402

set -e

# make sure local tmp dir exists
[[ -d /tmp/rsync.tilt ]] || mkdir /tmp/rsync.tilt

rsync_path=/bin/rsync.tilt

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
## TODO: option for windows bin, depending on container OS
tar_path=${0%/*}/rsync.tilt.tar
kubectl exec deployment/example-rails -- /bin/sh -c "ls $rsync_path > /dev/null" 2> /dev/null || cat $tar_path | kubectl $namespace exec -i $K8S_OBJECT -- /bin/sh -c "tar -xf - -C /bin/"

exec kubectl $namespace exec -i $K8S_OBJECT -- "$@"

