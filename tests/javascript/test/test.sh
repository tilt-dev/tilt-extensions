#!/bin/bash

set -x

cd $(dirname $0)

tilt ci -f Tiltfile.test
