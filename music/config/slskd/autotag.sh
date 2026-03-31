#!/usr/bin/bash

download_path=$(echo "${SLSKD_SCRIPT_DATA}" | jq -r .localDirectoryName)

AUTH_TOKEN=$(echo -n ":${WRTAG_WEB_API_KEY}" | base64)

wget -q -O/dev/null \
    --header="Authorization: Basic ${AUTH_TOKEN}" \
    --post-data="path=${download_path}" \
    "http://music_wrtag:7373/op/move"
