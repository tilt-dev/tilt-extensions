#!/bin/sh

set -ex

cd "$(dirname "$0")"

tilt ci
tilt down
