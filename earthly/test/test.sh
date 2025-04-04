#!/bin/sh

set -ex

cd "$(dirname "$0")"

tilt ci -f ./Tiltfile
tilt down -f ./Tiltfile

tilt ci -f ./restart.Tiltfile
tilt down -f ./restart.Tiltfile
