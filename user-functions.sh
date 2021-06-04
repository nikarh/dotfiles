#!/bin/bash -e
# shellcheck disable=SC2155

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
            code --install-extension "$EXTENSION";
        fi
    done
}

function ln-all {
    for FILE in "$@"; do
        if [[ -f "$FROM/$FILE.desktop" ]]; then
            ln -sf "$FROM/$FILE.desktop" "$TO"
        fi
    done
}
