#!/bin/bash

set -e

pid=
cleanup() {
    kill $pid
    tilt down
}
trap cleanup EXIT

tilt ci "$@"
kubectl wait deployment/html --for=condition=available
kubectl port-forward service/html 8008:80 &
pid=$!
while true; do
    if nc -vz localhost 8008; then
        break
    fi
done

# Test that nginx is responding
curl -sf http://localhost:8008 | grep "Test deployment_create"
