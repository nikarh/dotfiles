#!/bin/bash -e

function latest-release {
    local URL="$(curl -s "https://api.github.com/repos/$1/releases/latest" \
        | grep browser_download_url \
        | grep "$2" \
        | head -n 1 \
        | sed -n 's/.*": "\(.*\)"/\1/p')"
    curl -s -fLo "$3" --create-dirs "$URL"
}

ARCH="$(uname -m)"

if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" == "armv7l" ]; then
    ARCH="arm"
elif [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
fi

if ! type -P yq > /dev/null && [ ! -f ~/.local/bin/yq ]; then
    echo Installing yq
    latest-release mikefarah/yq "yq_linux_$ARCH" \
        ~/.local/bin/yq
    chmod +x ~/.local/bin/yq
fi

export PATH=$PATH:~/.local/bin/
