#!/bin/sh

cd $(dirname $0)

set -ex
configmap/test/test.sh
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
tests/golang/test/test.sh
tests/javascript/test/test.sh
