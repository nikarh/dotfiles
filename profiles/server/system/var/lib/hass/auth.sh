#!/usr/bin/env bash
set -e

authelia=http://authelia:8080
username="$(echo -n "$username" | jq -aRs .)"
password="$(echo -n "$password" | jq -aRs .)"

response="$(curl -si -w "\n%{size_header},%{size_download}" \
    "$authelia/api/firstfactor" \
    -H 'Content-Type: application/json' \
    -d '{
       "username": '"$username"',
       "password": '"$password"',
       "targetURL": "https://hass.home.arhipov.net",
       "requestMethod": "GET",
       "keepMeLoggedIn": true
    }')"

headerSize=$(sed -n '$ s/^\([0-9]*\),.*$/\1/ p' <<< "${response}")
bodySize=$(sed -n '$ s/^.*,\([0-9]*\)$/\1/ p' <<< "${response}")
headers="${response:0:${headerSize}}"
body="${response:${headerSize}:${bodySize}}"
cookie="$(grep -i ^set-cookie <<< "$headers" | cut -c 13-)"

if [[ "$(echo $body | jq -r .status)" == "OK" ]]; then
    response="$(curl -s \
        -b "$cookie" \
        "$authelia/api/user/info"
    )"
    display_name="$(echo "$response" | jq -r .data.display_name)"

    echo name = $display_name
    exit 0
fi
exit 1