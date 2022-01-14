#!/bin/bash

cd "$(dirname "$0")"

set -ex
tilt ci
tilt down --delete-namespaces

tilt alpha tiltfile-result >/dev/null
