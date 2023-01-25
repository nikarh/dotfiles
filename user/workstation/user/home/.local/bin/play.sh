#!/usr/bin/env bash
cd "$(dirname "$(readlink -f "$0")")" || exit

function expand {
    cat - | sed -r "s:~:/home/$USER:g"
}

CONFIG_DIR="/srv/games/.config"
RUNTIMES="/srv/games/.wine/runtimes"
LIBRARIES="/srv/games/.wine/libraries"

SGDB_TOKEN="$(cat $CONFIG_DIR/steamgriddb_key)"
YAML="$CONFIG_DIR/games.yaml"

function file-get {
    curl -s -fLo "$2" --create-dirs "$1"
}

function latest-release {
    curl -s "https://api.github.com/repos/$1/releases" \
        | jq -r '.[].assets[].browser_download_url' \
        | grep "$2" \
        | head -n 1
}

function prepare-runtime {
    mkdir -p "$RUNTIMES"

    local version="$1"
    if [[ "$version" == "default" ]]; then
        version="lutris-GE-Proton.*-x86_64"
    fi

    local url="$(latest-release GloriousEggroll/wine-ge-custom "wine-$version\.tar\.xz$")"
    local version=$(echo $url | awk -F'/' '{print $NF}' | awk -F'.tar.xz' '{print $1}' | cut -c 6-)

    ln -sf "$RUNTIMES/$version" "$RUNTIMES/default"
    if ! [ -d "$RUNTIMES/$version" ]; then
        echo Downloading "$version"
        file-get "$url" "$RUNTIMES/wine.tar.xz"
        tar -xf "$RUNTIMES/wine.tar.xz" -C "$RUNTIMES" && rm "$RUNTIMES"/wine.tar.xz
    fi
}

function update-libaries {
    mkdir -p "$LIBRARIES"
    mkdir -p "$LIBRARIES/dxvk-nvapi"
    file-get "$(latest-release Sporif/dxvk-async "dxvk-async.*\.tar\.gz$")" "$LIBRARIES/dxvk-async.tar.gz"
    file-get "$(latest-release jp7677/dxvk-nvapi "dxvk-nvapi.*\.tar\.gz$")" "$LIBRARIES/dxvk-nvapi.tar.gz"
    file-get "$(latest-release HansKristian-Work/vkd3d-proton "vkd3d-proton.*\.tar\.zst$")" "$LIBRARIES/vkd3d-proton.tar.zst"

    tar -xf "$LIBRARIES/dxvk-async.tar.gz" -C "$LIBRARIES" && mv "$LIBRARIES"/dxvk-async-* "$LIBRARIES"/dxvk-async && rm "$LIBRARIES"/dxvk-async.tar.gz
    tar -xf "$LIBRARIES/vkd3d-proton.tar.zst" -C "$LIBRARIES" && mv "$LIBRARIES"/vkd3d-proton-* "$LIBRARIES"/vkd3d-proton && rm "$LIBRARIES"/vkd3d-proton.tar.zst
    tar -xf "$LIBRARIES/dxvk-nvapi.tar.gz" -C "$LIBRARIES"/dxvk-nvapi && rm "$LIBRARIES"/dxvk-nvapi.tar.gz

    if ! [ -f "$LIBRARIES"/dxvk-nvapi/setup_dxvk_nvapi.sh ]; then
        file-get "https://aur.archlinux.org/cgit/aur.git/plain/setup_dxvk_nvapi.sh?h=dxvk-nvapi-mingw" \
            "$LIBRARIES"/dxvk-nvapi/setup_dxvk_nvapi.sh
    fi

    chmod +x "$LIBRARIES"/*/*.sh
}

function sync-to-sunshine {
    local BANNERS="$CONFIG_DIR/banners"
    mkdir -p "$HOME/.config/sunshine"
    mkdir -p "$BANNERS"

    local CONFIG='{"env": {"PATH": "$(PATH):$(HOME)\/.local\/bin"}, "apps": []}'

    while read line; do
        local game="$(echo $line | awk '{print $2}')"
        local game_id="$(cat "$YAML" | yq ".games[\"$game\"].steamgriddb_id // \"\"")"

        if [[ "$(cat "$YAML" | yq ".games[\"$game\"].sunshine")" == "false" ]]; then
            continue
        fi

        local game_data="$(jq --null-input \
            --arg name "$(cat "$YAML" | yq ".games[\"$game\"].name")" \
            --arg cmd "$(realpath "$0") $game" \
            --arg image "$BANNERS/$game_id.png" \
            '[{"name": $name, "output": "", "cmd": $cmd, "image-path": $image}]')"

        
        if [ -n "$game_id" ] && [ ! -f "$BANNERS/$game_id.png" ]; then
            local BANNER_URL="$(curl -H "Authorization: Bearer $SGDB_TOKEN" \
                "https://www.steamgriddb.com/api/v2/grids/game/$game_id" \
                | jq -r '([.data[] | select(.width == 600)][0] | .url) // .data[0].url')"

            curl "$BANNER_URL" -o "$BANNERS/$game_id.png.orig"
            convert "$BANNERS/$game_id.png.orig" "$BANNERS/$game_id.png"
            rm "$BANNERS/$game_id.png.orig"
        fi

        CONFIG="$(echo "$CONFIG" | jq ".apps += $game_data")"
    done <<< "$(cat "$YAML" | yq '.games | keys')"

    echo $CONFIG | jq >| "$HOME/.config/sunshine/apps_linux.json"
}

function create-desktop-files {
    local ICONS="$CONFIG_DIR/icons"
    local APPS="$HOME/.local/share/applications/gamesh"
    mkdir -p "$ICONS"

    rm -f "$APPS"/*
    mkdir -p "$APPS"

    while read line; do
        local game="$(echo $line | awk '{print $2}')"
        local game_id="$(cat "$YAML" | yq ".games[\"$game\"].steamgriddb_id // \"\"")"

        if [[ "$(cat "$YAML" | yq ".games[\"$game\"].desktop")" == "false" ]]; then
            continue
        fi

        if [ -n "$game_id" ] && [ ! -f "$ICONS/$game_id.png" ]; then
            local ICON_URL="$(curl -H "Authorization: Bearer $SGDB_TOKEN" \
                "https://www.steamgriddb.com/api/v2/icons/game/$game_id" \
                | jq -r '.data[0].thumb')"

            curl "$ICON_URL" -o "$ICONS/$game_id.png"
        fi

        printf "%s\n" \
            "[Desktop Entry]" \
            "Type=Application" \
            "Version=1.0" \
            "Name=$(cat "$YAML" | yq ".games[\"$game\"].name")" \
            "Path=$(dirname "$(realpath "$0")")" \
            "Exec=$(realpath "$0") $game" \
            "Icon=$ICONS/$game_id.png" \
            "Terminal=false" \
            "Categories=Games;" > "$APPS/$game.desktop"

    done <<< "$(cat "$YAML" | yq '.games | keys')"
}

function run-wine {
    local GAME="$1"

    local RUNTIME=$(cat "$YAML" | yq '.runtime // "default"' | expand)
    local PREFIXES=$(cat "$YAML" | yq .prefixes | expand)
    local WINE="$RUNTIMES/$RUNTIME"

    # Download runtime
    if ! [ -d "$WINE" ]; then
        prepare-runtime "$RUNTIME"
    fi

    # Download libraries
    if ! [ -d "$LIBRARIES/dxvk-nvapi" ]; then
        update-libaries
    fi

    eval "$(cat "$YAML" | yq -o p '.env' | sed -r 's/([^ ]+) = (.*)/export \1="\2"/')" > /dev/null

    local DXVK="$(cat "$YAML" | yq ".games[\"$GAME\"].dxvk")"
    local VKD3D="$(cat "$YAML" | yq ".games[\"$GAME\"].vkd3d")"
    local PREFIX="$(cat "$YAML" | yq ".games[\"$GAME\"].prefix")"
    local GAME_DIR="$(cat "$YAML" | yq ".games[\"$GAME\"].dir")"
    local GAME_EXE="$(cat "$YAML" | yq ".games[\"$GAME\"].run")"

    eval "$(cat "$YAML" | yq -o p ".games[\"$GAME\"].env" | sed -r 's/([^ ]+) = (.*)/export \1="\2"/')" > /dev/null

    export PATH="$WINE/bin:$PATH"
    export WINEPREFIX="$PREFIXES/$PREFIX"
    export DXVK_CONFIG_FILE="$CONFIG_DIR/dxvk.conf"

    # Init prefix
    if [ ! -d "$WINEPREFIX" ]; then
        echo Initializing prefix
        WINEDLLOVERRIDES=winemenubuilder.exe=d \
            wine __INITPREFIX > /dev/null 2>&1 || true
        wineserver --wait
    fi

    cd "$WINEPREFIX"

    # Replace symlinks to $HOME with directories
    find "$WINEPREFIX/drive_c/users/$USER" -maxdepth 1 -type l \
        -exec unlink {} \; \
        -exec mkdir {} \;

    # Install libraries for games
    local syswow="$WINEPREFIX/drive_c/windows/syswow64"
    if ! diff -q "$syswow/d3d11.dll" "$LIBRARIES/dxvk-async/x32"; then
        echo Installing dxvk...
        $LIBRARIES/dxvk-async/setup_dxvk.sh install
    fi

    if ! diff -q "$syswow/d3d12.dll" "$LIBRARIES/vkd3d-proton/x86"; then
        echo Installing vkd3d-proton...
        $LIBRARIES/vkd3d-proton/setup_vkd3d_proton.sh install
    fi

    if ! diff -q "$syswow/nvapi.dll" "$LIBRARIES/dxvk-nvapi/x32"; then
        echo Installing dxvk-nvapi...
        $LIBRARIES/dxvk-nvapi/setup_dxvk_nvapi.sh install
    fi

    # Enable nvidia DLSS 2.0
    if [ -f /usr/lib/nvidia/wine/nvngx.dll ]; then
        echo Copying ngngx.dll
        cp /usr/lib/nvidia/wine/nvngx.dll "$WINEPREFIX/drive_c/windows/system32/"
        cp /usr/lib/nvidia/wine/_nvngx.dll "$WINEPREFIX/drive_c/windows/system32/"
    fi

    # Enable CUDA for DLSS 3.0 or PhysX. This is taken from wine-staging
    if [ -f /usr/lib/wine/x86_64-windows/nvcuda.dll ]; then
        echo Copying nvcuda
        cp /usr/lib/wine/x86_64-windows/nvcuda.dll "$WINEPREFIX/drive_c/windows/system32/"
        cp /usr/lib32/wine/i386-windows/nvcuda.dll "$WINEPREFIX/drive_c/windows/syswow64/"
    fi

    wineserver --wait

    echo "cd \"$GAME_DIR\""
    echo "export PATH=\"$WINE/bin:\$PATH\""
    echo "export WINEPREFIX=\"$PREFIXES/$PREFIX\""
    echo 'wine '\""$GAME_EXE"\" $(cat "$YAML" | yq ".games[\"$GAME\"].args // \"\"" | sed -r 's/- ([^ ]+)/\1/')

    cd "$GAME_DIR"
    gamemoderun mangohud wine "$GAME_EXE" ${@:2} $(cat "$YAML" | yq ".games[\"$GAME\"].args // \"\"" | sed -r 's/- ([^ ]+)/\1/')

    wineserver -k
}

function run-native {
    local GAME="$1"
    local RUN="$(cat "$YAML" | yq ".games[\"$GAME\"].run")"

    "$RUN" $(cat "$YAML" | yq ".games[\"$GAME\"].args // \"\"" | sed -r 's/- ([^ ]+)/\1/')
}

function run {
    local GAME="$1"

    if [ -z "$GAME" ]; then
        echo Provide game key as an argument:
        echo "$(cat "$YAML" | yq '.games | keys')"
        exit 1;
    fi

    if [[ "$(cat "$YAML" | yq ".games[\"$GAME\"]")" == "null" ]]; then
        echo Invalid game "$GAME", provide valid game key as an argument:
        echo "$(cat "$YAML" | yq '.games | keys')"
        exit 1;
    fi

    local TYPE="$(cat "$YAML" | yq ".games[\"$GAME\"].type // \"wine\"")"

    case "$TYPE" in
        native)
            run-native "$1" "${@:2}";;
        "wine")
            run-wine "$1" "${@:2}";;
        *)
            echo "invalid type";;
    esac
}

function refresh {
    if ! sha1sum --quiet --check "$YAML.sha1" 2>/dev/null; then
        sync-to-sunshine
        create-desktop-files
        sha1sum "$YAML" >| "$YAML.sha1"
    fi
}

refresh

if [ "$1" == "watch" ]; then
    while inotifywait -e modify "$YAML"; do
        echo "Refreshing sunshine config and desktop files"
        refresh;
    done
else
    run "$1" "${@:2}"
fi
