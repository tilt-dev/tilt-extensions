#!/bin/bash

# Adapted from Karl Bunch's post on Server Fault:
# https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod/887402#887402

if [ -z "$KRSYNC_STARTED" ]; then
  export KRSYNC_STARTED=true
  exec rsync --rsync-path=/app/rsync.tilt --blocking-io --rsh "$0" $@
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
cat $tar_path | kubectl $namespace exec -i deployment/$depl -- /bin/sh -c 'ls rsync.tilt 2>/dev/null && cat>/dev/null || tar -xf -' > /dev/null

exec kubectl $namespace exec -i deployment/$depl -- "$@"

