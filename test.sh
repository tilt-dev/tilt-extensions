#!/bin/sh

cd $(dirname $0)

set -ex
git_resource/test/test.sh
namespace/test/test.sh
helm_remote/test/test.sh
