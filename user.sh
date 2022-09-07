#!/bin/bash -e
# shellcheck disable=SC2155
cd "$(dirname "${BASH_SOURCE[0]}")"

function prepend() {
    awk "{print \"$1\" \$0}"
}

function section() {
    echo -e "\e[1m\e[34m$*\e[0m"
}

function git-get {
    if [ ! -d "$2" ]; then
        echo "Cloning $1 to $2"
        git clone -q "$1" "$2"
    else
        echo "Updating $1 in $2"
        git -C "$2" pull -q;
    fi
}

function file-get {
    echo "Downloading $1 to $2"
    curl -s -fLo "$2" --create-dirs "$1"
}

function install-code-extensions {
    local INSTALLED_EXTENSIONS=$(code --list-extensions)
    for EXTENSION in "$@"; do
        if ! echo "$INSTALLED_EXTENSIONS" | grep -qw "$EXTENSION"; then
            code --install-extension "$EXTENSION" 2>&1;
        fi
    done

    local UNEXPECTED=$(comm --output-delimiter=--- -3 \
        <(echo "$INSTALLED_EXTENSIONS" | tr " " "\n" | sort) \
        <(echo "$@" | tr " " "\n" | sort) | grep -v ^---)

    echo Unexpected extensions installed: $UNEXPECTED
}

function ln-all {
    for FILE in "$@"; do
        if [[ -f "$FROM/$FILE.desktop" ]]; then
            ln -sf "$FROM/$FILE.desktop" "$TO"
        fi
    done
}



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
