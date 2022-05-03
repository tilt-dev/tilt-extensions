#!/bin/bash

set -ex

cd "$(dirname "$0")"
./test-docker-fail.sh
./test-custom-fail.sh
./test-custom-deploy.sh
