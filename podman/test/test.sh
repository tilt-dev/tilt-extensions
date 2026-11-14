#!/bin/sh

# Needs DOCKER_HOST set to the podman socket.

set -ex

cd "$(dirname "$0")"

image() {
  kubectl get deployment example-podman -o jsonpath='{.spec.template.spec.containers[0].image}'
}

tilt ci
first=$(image)
tilt ci
second=$(image)
tilt down

# An unchanged image must keep its tag.
test "$first" = "$second"
