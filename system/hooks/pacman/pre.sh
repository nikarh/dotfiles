#!/bin/bash -e

export ALL_PACKAGES_TO_INSTALL=""

function pkg {
    local installed=$(pacman -Q | awk '{ print $1 }' | sort)
    local requested=$(echo "$@" | tr " " "\n" | sort | uniq)
    local to_install=$(comm --output-delimiter=--- -3 \
        <(echo "$requested") \
        <(echo "$installed") | grep -v ^---)
    local COMMAND="${COMMAND:-yay --pgpfetch}"
    if ! command -v yay &> /dev/null; then
        COMMAND="sudo pacman"
    fi

    export ALL_PACKAGES_TO_INSTALL="$ALL_PACKAGES_TO_INSTALL $requested"

    if [ -n "$to_install" ]; then
        # shellcheck disable=SC2086
        $COMMAND --noconfirm -S --needed $to_install
    fi
}

function pkg-local {
    local package="$(cat "$1/PKGBUILD" | grep ^pkgname | awk -F'=' '{print $2}')"
    local current_version="$(cat "$1/PKGBUILD" | grep '^\(pkgver=\|pkgrel=\)' | tr -d '\n' | sed -r 's/pkgver=(.*)pkgrel=(.*)/\1-\2/')"
    local installed=$(pacman -Q "$package" 2> /dev/null)
    local installed_version=$(echo $installed | awk '{ print $2 }')

    if [ "$installed_version" != "$current_version" ]; then
        local built_file="$package-$current_version-x86_64.pkg.tar.zst"
        if [ ! -f "$1/$built_file" ]; then

            (
                cd "$1"
                makepkg --noconfirm -f
            )
        fi
        sudo pacman -U --noconfirm "$1/$built_file"
    fi

    export ALL_PACKAGES_TO_INSTALL="$ALL_PACKAGES_TO_INSTALL $package"
}

function unpkg {
    local COMMAND="${COMMAND:-yay}"
    $COMMAND -Rnsc --noconfirm "$@" 2> /dev/null
}
