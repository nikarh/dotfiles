#!/usr/bin/env bash
set -e

authelia=http://authelia:8080
hass=https://hass.home.arhipov.net

username="$(echo -n "$username" | jq -aRs .)"
password="$(echo -n "$password" | jq -aRs .)"

response="$(curl -si -w "\n%{size_header},%{size_download}" \
    "$authelia/api/firstfactor" \
    -H 'Content-Type: application/json' \
    -d '{
       "username": '"$username"',
       "password": '"$password"',
       "targetURL": "'"$hass"'",
       "requestMethod": "GET",
       "keepMeLoggedIn": true
    }')"

headerSize=$(sed -n '$ s/^\([0-9]*\),.*$/\1/ p' <<< "${response}")
bodySize=$(sed -n '$ s/^.*,\([0-9]*\)$/\1/ p' <<< "${response}")
headers="${response:0:${headerSize}}"
body="${response:${headerSize}:${bodySize}}"
cookie="$(grep -i ^set-cookie <<< "$headers" | cut -c 13-)"

if [[ "$(echo $body | jq -r .status)" != "OK" ]]; then
    exit 1
fi

# Verify that user has access to hass
curl -sf \
    -b "$cookie" \
    -H 'X-Original-Url: '$hass'' -H 'X-Forwarded-Method: GET' \
    "$authelia/api/verify"

# Get display name
response="$(curl -sf \
    -b "$cookie" \
    "$authelia/api/user/info"
)"
display_name="$(echo "$response" | jq -r .data.display_name)"

echo name = $display_name
exit 0