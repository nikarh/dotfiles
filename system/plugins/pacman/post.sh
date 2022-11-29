#!/bin/bash -e

local COMMAND="${COMMAND:-yay}"
if ! command -v yay; then
    COMMAND="sudo pacman"
fi

# Upgrade all packages
echo

$COMMAND -Syu --noconfirm
$COMMAND -Rnscu --noconfirm "$($COMMAND -Qtdq)" 2> /dev/null || true

EXPLICITLY_INSTALLED=$(pacman -Qqett | sort)
INSTALLED_BY_SETUP=$(echo "$ALL_PACKAGES_TO_INSTALL" | tr " " "\n" | sort)

UNEXPECTED=$(comm --output-delimiter=--- -3 \
    <(echo "$EXPLICITLY_INSTALLED") \
    <(echo "$INSTALLED_BY_SETUP") | grep -v ^---)

if [[ -n "$UNEXPECTED" ]]; then
    # shellcheck disable=SC2086
    echo Unexpected packages installed: $UNEXPECTED
fi
