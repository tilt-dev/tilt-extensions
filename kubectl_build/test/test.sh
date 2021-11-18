#!/bin/bash

cd "$(dirname "$0")"

set -ex

# kubectl build sometimes has issues on circleci
# https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/issues/109
#
# let's try to create a buildkit instance manually
# to see if it helps. Specifying the runtime
# manually helps with startup time.
kubectl buildkit create --runtime=containerd

tilt ci
tilt down
