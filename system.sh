#!/bin/bash -e
cd "$(dirname "${BASH_SOURCE[0]}")"

export REBUILD_INITRD=0
export ALL_PACKAGES_TO_INSTALL=""

function require-arg {
    local varname="ARGS_$1"
    if [ -z "${!varname}" ]; then
        echo $1 is required
        exit 1
    fi
}

function pkg {
    local installed=$(pacman -Q | awk '{ print $1 }' | sort)
    local requested=$(echo "$@" | tr " " "\n" | sort | uniq)
    local to_install=$(comm --output-delimiter=--- -3 \
        <(echo "$requested") \
        <(echo "$installed") | grep -v ^---)
    local COMMAND="${COMMAND:-yay --pgpfetch}"

    export ALL_PACKAGES_TO_INSTALL="$ALL_PACKAGES_TO_INSTALL $requested"

    if [ -n "$to_install" ]; then
        # shellcheck disable=SC2086
        $COMMAND --noconfirm -S --needed $to_install
    fi
}

function pkg-local {
    local package="$(cat "$1/PKGBUILD" | grep pkgname | awk -F'=' '{print $2}')"
    local current_version="$(cat "$1/PKGBUILD" | grep 'pkgver\|pkgrel' | tr -d '\n' | sed -r 's/pkgver=(.*)pkgrel=(.*)/\1-\2/')"
    local installed=$(pacman -Q "$package" 2> /dev/null)
    local installed_version=$(echo $installed | awk '{ print $2 }')

    if [ "$installed_version" != "$current_version" ]; then
        local built_file="$package-$current_version-x86_64.pkg.tar.zst"
        if [ ! -f "$1/$built_file" ]; then

            (
                cd "$1"
                makepkg --noconfirm
            )
        fi
        exit 1
        yay -U --noconfirm "$1/$built_file"
    fi

    export ALL_PACKAGES_TO_INSTALL="$ALL_PACKAGES_TO_INSTALL $package"
}

function unpkg {
    local COMMAND="${COMMAND:-yay}"
    $COMMAND -Rnsc --noconfirm "$@" 2> /dev/null
}

function create-groups {
    local ALL_GROUPS=$(cut -d: -f1 /etc/group)
    for group in "$@"; do
        if ! echo "$ALL_GROUPS" | grep -qw "$group"; then
            sudo groupadd "$group"
        fi
    done
}

function add-user-to-groups {
    for group in "$@"; do
        if grep -q "$group" /etc/group && ! groups "$USER" | grep -qw "$group"; then
            sudo gpasswd --add "$USER" "$group"
        fi
    done
}

function add-module-to-initrd {
    if ! grep -q "^MODULES.*${1}" /etc/mkinitcpio.conf; then
        sudo sed -E -i "s/^(MODULES=\()(.*)/\1${1} \2/; s/^(MODULES.*) (\).*)/\1\2/" /etc/mkinitcpio.conf
        export REBUILD_INITRD=1
    fi
}

function remove-module-from-initrd {
    if grep -q "^MODULES.*${1}" /etc/mkinitcpio.conf; then
        sudo sed -E -i "s/^(MODULES=\()(.*)${1}(.*)/\1\2\3/; s/^(MODULES=\() (.*)/\1\2/; s/^(MODULES=\(.*) \)/\1)/" /etc/mkinitcpio.conf
        export REBUILD_INITRD=1
    fi
}

PROFILE="system/profiles/$PROFILE.yaml"

if [[ -z "$PROFILE" ]] || [[ ! -f "$PROFILE" ]]; then
    # shellcheck disable=SC2046
    echo Invalid profile, use one of the following:
    ls profiles | tr ' ' '\n' | sed -r 's/^(.*).yaml/  \1/'
    exit 1
fi

COMMAND="sudo pacman" pkg go-yq

# Install modules
while read line ; do
    INDEX=$(echo $line | awk '{print $2}')
    NAME=$(cat "$PROFILE" | yq ".modules[$INDEX].name")
    ARGS=$(cat "$PROFILE" | yq -o p ".modules[$INDEX]" | sed -r 's/([^ ]+) = (.*)/ARGS_\1="\2"/')
    export ROOT="$(pwd)/system/modules/$NAME"

    eval "$ARGS" > /dev/null
    echo Installing module $NAME
    source "$ROOT/install.sh"
    
    eval "$(echo "$ARGS" | sed -r 's/^([^=]+)=.*/unset \1/')" > /dev/null
done <<< "$(cat "$PROFILE" | yq '.modules | keys')"

# Rebuild initrd if required
if [[ "$REBUILD_INITRD" -eq 1 ]]; then
    sudo mkinitcpio -p linux
fi

# Upgrade all packages
echo
yay -Syu --noconfirm
yay -Rnscu --noconfirm "$(yay -Qtdq)" 2> /dev/null || true

EXPLICITLY_INSTALLED=$(pacman -Qqett | sort)
INSTALLED_BY_SETUP=$(echo "$ALL_PACKAGES_TO_INSTALL" | tr " " "\n" | sort)

UNEXPECTED=$(comm --output-delimiter=--- -3 \
    <(echo "$EXPLICITLY_INSTALLED") \
    <(echo "$INSTALLED_BY_SETUP") | grep -v ^---)

if [[ -n "$UNEXPECTED" ]]; then
    # shellcheck disable=SC2086
    echo Unexpected packages installed: $UNEXPECTED
fi
