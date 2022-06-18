#!/bin/bash -e
# shellcheck disable=SC2155
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./user-functions.sh

if [[ -z "$USER_PROFILE" ]] || [[ ! -d "user/$USER_PROFILE" ]]; then
    # shellcheck disable=SC2046
    echo Invalid \$USER_PROFILE, use one of the following: $(ls user)
    exit 1
fi


if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Generating ssh key..."
    ssh-keygen -C "$HOSTNAME" -f "$HOME/.ssh/id_rsa" -P "";
fi

# shellcheck disable=SC1090
source "./user/$USER_PROFILE/user.sh"
