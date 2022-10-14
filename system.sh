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

PROFILE="system/profiles/$PROFILE.yaml"

if [[ -z "$PROFILE" ]] || [[ ! -f "$PROFILE" ]]; then
    # shellcheck disable=SC2046
    echo Invalid profile, use one of the following:
    ls profiles | tr ' ' '\n' | sed -r 's/^(.*).yaml/ \1/'
    exit 1
fi

# Install yq
source "$(pwd)/system/plugins/yq/pre.sh"

# Pre-setup plugins
while read line; do
    INDEX=$(echo $line | awk '{print $2}')
    if [[ -f "$(pwd)/system/plugins/$INDEX/pre.sh" ]]; then
        echo Running pre-setup script for $INDEX
        source "$(pwd)/system/plugins/$INDEX/pre.sh"
    fi
done <<< "$(cat "$PROFILE" | yq '.plugins')"

# Install modules
while read line; do
    INDEX=$(echo $line | awk '{print $2}')
    NAME=$(cat "$PROFILE" | yq ".modules[$INDEX].name")
    ARGS=$(cat "$PROFILE" | yq -o p ".modules[$INDEX]" | sed -r 's/([^ ]+) = (.*)/ARGS_\1="\2"/')
    export ROOT="$(pwd)/system/modules/$NAME"

    eval "$ARGS" > /dev/null
    echo Installing module $NAME
    source "$ROOT/install.sh"
    
    eval "$(echo "$ARGS" | sed -r 's/^([^=]+)=.*/unset \1/')" > /dev/null
done <<< "$(cat "$PROFILE" | yq '.modules | keys')"

# Post-setup plugins
while read line; do
    INDEX=$(echo $line | awk '{print $2}')
    if [[ -f "$(pwd)/system/plugins/$INDEX/post.sh" ]]; then
        echo Running post-setup script for $INDEX
        source "$(pwd)/system/plugins/$INDEX/post.sh"
    fi
done <<< "$(cat "$PROFILE" | yq '(.plugins // []) | reverse')"