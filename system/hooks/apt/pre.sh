#!/bin/bash -e

export ALL_PACKAGES_TO_INSTALL=""

function pkg {
    local requested=$(echo "$@" | tr " " "\n" | sort | uniq | tr "\n" " ")
    local to_install=()
    local package

    for package in $requested; do
        if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"; then
            to_install+=("$package")
        fi
    done

    export ALL_PACKAGES_TO_INSTALL="$ALL_PACKAGES_TO_INSTALL $requested"

    if [ ${#to_install[@]} -ne 0 ]; then
        sudo apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${to_install[@]}"
    fi
}

function unpkg {
    sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y "$@" || true
}
