#!/bin/bash
#
# Reconcilation for the state of every configmap
#
# 1) Iterate through all the configmaps.
# 2) Gather all the enabled ports.
# 3) Check to make sure the ngrok config is what we expect.

auth_env="$TILT_NGROK_AUTH"

set -euo pipefail

config_file="$1"

tunnels=()
names="$(tilt get configmap -l tilt.dev/managed-by=tilt-extensions.ngrok -o name | sort -u)"
auth=""
if [[ "$auth_env" != "" ]]; then
    auth="
    auth: \"$auth_env\""
fi

for name in $names;
do
    short=${name#configmap.tilt.dev/}
    cm="$(tilt get configmap "$short" -o json)"
    value="$(echo "$cm" | jq -r ".data.enabled")"
    port_list="$(echo "$cm" | jq -r '.data.ports')"
    location="$(echo "$cm" | jq -r ".data.resource")"
    if [[ "$value" == "true" ]]; then
        for port in $port_list;
        do
            tunnel="  \"$location:$port\":
    proto: http
    addr: $port
    bind_tls: false$auth"
            tunnels+=("$tunnel")
        done
    fi
done

new_config="tunnels:"
for tunnel in "${tunnels[@]}";
do
    new_config="$new_config
$tunnel"
done

old_config="$(cat "$config_file")"
if [[ "$new_config" != "$old_config" ]]; then
    echo -n "$new_config" > "$config_file"
fi
