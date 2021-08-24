#!/bin/bash
#
# Run kubefwd, assuming we already have sudo privs.
# Build up the arguments to kubefwd from the namespaces in the trigger file.

set -euo pipefail

flags=()
while read namespace; do
    if [[ "$namespace" == "" ]]; then
      continue
    fi
    flags+=("-n=$namespace")
done < "$TRIGGER"

if [ ${#flags[@]} -eq 0 ]; then
    echo "No namespaces to kubefwd"
    exit 0
fi

set -ex
exec "$KUBEFWD" svc "${flags[@]}"
