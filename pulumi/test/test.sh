#!/bin/bash

cd "$(dirname "$0")"

set -ex

# install pulumi deps
yarn install

tilt ci
tilt down
