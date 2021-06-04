#!/bin/bash -e
# shellcheck disable=SC2155
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./user-functions.sh

if [[ -z "$PROFILE" ]] || [[ ! -d "profiles/$PROFILE" ]]; then
    # shellcheck disable=SC2046
    echo Invalid \$PROFILE, use one of the following: $(ls profiles)
    exit 1
fi


if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Generating ssh key..."
    ssh-keygen -C "$HOSTNAME" -f "$HOME/.ssh/id_rsa" -P "";
fi

# shellcheck disable=SC1090
source "./profiles/$PROFILE/user.sh"
