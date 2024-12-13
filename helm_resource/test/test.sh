#!/bin/sh

set -ex

cd "$(dirname "$0")"

kubectl config set-cluster dummy --server=http://localhost:1234
kubectl config set-context dummy --cluster=dummy
kubectl config use-context dummy

tilt ci --context=kind-kind
tilt down --context=kind-kind
