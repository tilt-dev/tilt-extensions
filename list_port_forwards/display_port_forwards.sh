#!/usr/bin/env bash

set -euo pipefail

command -v jq >/dev/null || (echo "jq not installed :(" && exit 1)  # ensure jq is installed

echo "__(.)= __(.)=    =(.)__ =(.)__"
echo "\\___)  \\___)      (___/  (___/"

echo "---- Port forwards in use ----"

jqquery='.items[] | { name:.metadata.annotations."tilt.dev/resource", p:.spec.forwards[] } | "\(.name):\(.p.containerPort) -> \(.p.host):\(.p.localPort)"'

tilt get portforwards -o json | jq -r "$jqquery"

echo "------------------------------"
