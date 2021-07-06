#!/usr/bin/env bash

echo "__(.)= __(.)=    =(.)__ =(.)__"
echo "\___)  \___)      (___/  (___/"

echo "---- Port forwards in use ----"

jqquery='.items[] | { name:.metadata.annotations."tilt.dev/resource", p:.spec.forwards[] } | "\(.name):\(.p.containerPort) -> \(.p.host):\(.p.localPort)"'

startquote='s/^"//'
endquote='s/"$//'

tilt get portforwards -o json | jq "$jqquery" | sed -e "$startquote" -e "$endquote"

echo "------------------------------"
