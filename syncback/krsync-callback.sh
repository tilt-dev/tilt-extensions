#!/bin/bash

set -e

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

# $K8S_OBJECT is intentionally not quoted here so -n/-c flags can be
# parsed by kubectl
exec kubectl exec -i $K8S_OBJECT -- "$@"

