#!/bin/bash

set -x

cd "$(dirname "$0")" || exit 1

tilt ci -f Tiltfile.test
