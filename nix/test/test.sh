#!/bin/sh

set -ex

cd "$(dirname "$0")"
export TILT_PORT=9393

tilt ci
tilt down
