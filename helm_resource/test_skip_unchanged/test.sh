#!/bin/sh

set -ex

cd "$(dirname "$0")"

(cd .. && python3 -m unittest fingerprint_test apply_helper_test)

trap 'rm -f chart/values.yaml; tilt down' EXIT

release=skip-unchanged
namespace=helm-resource-skip-unchanged

revision() {
  helm status "$release" --namespace "$namespace" --output json |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["version"])'
}

tilt ci
installed=$(revision)

# Nothing changed, so the revision must stay the same.
tilt ci
[ "$(revision)" = "$installed" ]

# Delete an object outside of helm. The next run must upgrade the release to restore it.
kubectl delete configmap skip-unchanged-two --namespace "$namespace"
tilt ci
kubectl get configmap skip-unchanged-two --namespace "$namespace"
[ "$(revision)" != "$installed" ]

# Change the chart while Tilt is stopped. The next run must upgrade the release.
restored=$(revision)
echo 'hello: there' > chart/values.yaml
tilt ci
[ "$(revision)" != "$restored" ]
[ "$(kubectl get configmap skip-unchanged-one --namespace "$namespace" -o jsonpath='{.data.hello}')" = there ]
