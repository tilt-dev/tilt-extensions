#!/bin/sh

cd $(dirname $0)

set -ex
file_sync_only/test/test.sh
git_resource/test/test.sh
namespace/test/test.sh
helm_remote/test/test.sh
secret/test/test.sh
