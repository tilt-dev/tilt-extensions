#!/bin/sh

set -ex

cd "$(dirname "$0")"

tilt ci
tilt down

if kubectl get crd bars.helm-resource.tilt-x.dev >/dev/null 2>&1; then
  echo >&2 "crd 'bars.helm-resource.tilt-x.dev' was not cleaned up properly"
  exit 1
fi

if kubectl get crd foos.helm-resource.tilt-x.dev >/dev/null 2>&1; then
  echo >&2 "crd 'foos.helm-resource.tilt-x.dev' was not cleaned up properly"
  exit 1
fi
