#!/bin/sh

cd $(dirname $0)

set -ex
cert_manager/test/test.sh
configmap/test/test.sh

# TODO(milas): the prometheus resources need more CPU than
#   our CI KIND cluster can provide
# coreos_prometheus/test/test.sh

file_sync_only/test/test.sh
git_resource/test/test.sh
namespace/test/test.sh
helm_remote/test/test.sh
ko/test/test.sh

# TODO(nick): Currently it's a PITA to run podman in CI,
# so we've turned this off. You can still run it manually
# on a machine with podman installed.
#
# podman/test/test.sh

secret/test/test.sh
restart_process/test/test.sh
tilt_inspector/test/test.sh
tests/golang/test/test.sh
tests/javascript/test/test.sh
uibutton/test/test.sh
