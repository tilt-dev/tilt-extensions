#!/bin/bash

set -ex

cd $(dirname $0)

tilt ci -f distroless.Tiltfile
tilt down -f distroless.Tiltfile
