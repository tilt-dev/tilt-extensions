#!/bin/bash

set -ex

cd $(dirname $0)
./test-docker.sh
./test-custom.sh
./test-distroless.sh
