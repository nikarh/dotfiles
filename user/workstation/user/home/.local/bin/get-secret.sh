#!/bin/sh

# next, replace spaces with underscores
URL="${1// /_}"
# now, clean out anything that's not alphanumeric or an underscore
URL="${URL//[^a-zA-Z0-9_:/]/}"

SECRET="${2// /_}"
SECRET="${SECRET//[^A-Z0-9_]/}"

printf "url=${URL}\nusername=${SECRET}\n" | git-credential-keepassxc get --json | jq -r ".password"
