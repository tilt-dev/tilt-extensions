#!/bin/bash
# Helper script to trigger a button.

YAML=$(tilt get uibutton "sleep:update:cancel" -o yaml)
TIME=$(date '+%FT%T.000000Z')
# shellcheck disable=SC2001
NEW_YAML=$(echo "$YAML" | sed "s/lastClickedAt.*/lastClickedAt: $TIME/g")

# Currently, kubectl doesn't support subresource APIs.
# Follow this KEP:
# https://github.com/kubernetes/enhancements/issues/2590
# For now, we can handle it with curl.
curl -X PUT -H "Content-Type: application/yaml" -d "$NEW_YAML" \
   http://localhost:10350/proxy/apis/tilt.dev/v1alpha1/uibuttons/sleep:update:cancel/status
