#!/bin/bash
set -e

AUTHELIA_URL=https://authelia.files.home.arhipov.net
FORWARDED_HOST=https://sftp.files.home.arhipov.net

username="$(echo -n "$PAM_USER" | jq -aRs .)"
password="$(echo -n "$(cat -)" | jq -aRs .)"

response="$(curl -si -w "\n%{size_header},%{size_download}" \
    "$AUTHELIA_URL/api/firstfactor" \
    -H 'Content-Type: application/json' \
    -d '{
       "username": '"$username"',
       "password": '"$password"',
       "targetURL": "'"$FORWARDED_HOST"'",
       "requestMethod": "GET",
       "keepMeLoggedIn": true
    }')"

headerSize=$(sed -n '$ s/^\([0-9]*\),.*$/\1/ p' <<< "${response}")
bodySize=$(sed -n '$ s/^.*,\([0-9]*\)$/\1/ p' <<< "${response}")
headers="${response:0:${headerSize}}"
body="${response:${headerSize}:${bodySize}}"
cookie="$(grep -i ^set-cookie <<< "$headers" | cut -c 13- | awk '{print $1}')"

if [[ "$(echo $body | jq -r .status)" != "OK" ]]; then
    echo "Auth verify failed"
    exit 1
fi

# Verify that user has access to FORWARDED_HOST
curl -sf \
    -b "$cookie" \
    -H "X-Original-URL: $FORWARDED_HOST" -H 'X-Original-Method: GET' \
    "$AUTHELIA_URL/api/authz/auth-request"

exit 0
