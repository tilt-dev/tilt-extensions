#!/bin/sh

cd $(dirname $0)

set -ex
namespace/test/test.sh
helm_remote/test/test.sh
