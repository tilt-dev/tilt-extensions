#!/bin/bash
#
# Usage: ngrok-run.sh $CONFIG_FILE

set -euo pipefail

args=("start")
config_file="$1"
default_config_file="${TILT_NGROK_DEFAULT_CONFIG_FILE:-$HOME/.config/ngrok/ngrok.yml}"

if [[ -f "$default_config_file" ]]; then
    args+=("--config" "$default_config_file")
fi

args+=("--config" "$config_file")

if [[ "$(wc -l "$config_file" | awk '{print $1}')" == "0" ]]; then
    args+=("--none")
else
    args+=("--all")
fi

set -ex
ngrok "${args[@]}"
