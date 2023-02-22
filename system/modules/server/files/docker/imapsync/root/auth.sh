#!/bin/sh

set -o allexport
source /run/secrets/IMAP_AUTH set
set +o allexport

curl -s \
    --request POST \
    --data "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&refresh_token=${REFRESH_TOKEN}&grant_type=refresh_token" \
    https://accounts.google.com/o/oauth2/token \
    | jq -r '.access_token'