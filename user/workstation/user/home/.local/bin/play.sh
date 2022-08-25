#!/usr/bin/env bash
cd "$(dirname "$(readlink -f "$0")")" || exit

function expand {
    cat - | sed -r "s:~:/home/$USER:g"
}

CONFIG_DIR="$HOME/.config/run-games"
YAML="$CONFIG_DIR/games.yaml"

function sync-to-sunshine {
    local BANNERS="$CONFIG_DIR/banners"
    mkdir -p "$HOME/.config/sunshine"
    mkdir -p $BANNERS

    local CONFIG='{"env": {"PATH": "$(PATH):$(HOME)\/.local\/bin"}, "apps": []}'
    local SGDB_TOKEN="$(cat $CONFIG_DIR/steamgriddb_key)"

    while read line; do
        local game="$(echo $line | awk '{print $2}')"
        local game_id="$(cat "$YAML" | yq ".games[\"$game\"].steamgriddb_id")"
        local game_data="$(jq --null-input \
            --arg name "$(cat "$YAML" | yq ".games[\"$game\"].name")" \
            --arg cmd "$(realpath "$0") $game" \
            --arg image "$BANNERS/$game_id.png" \
            '[{"name": $name, "output": "", "cmd": $cmd, "image-path": $image}]')"

        
        if [ ! -f "$BANNERS/$game_id.png" ]; then
            local BANNER_URL=$(curl -H "Authorization: Bearer $SGDB_TOKEN" \
                "https://www.steamgriddb.com/api/v2/grids/game/$game_id" \
                | jq -r '.data[0].url')
            curl "$BANNER_URL" -o "$BANNERS/$game_id.png"
        fi

        CONFIG="$(echo "$CONFIG" | jq ".apps += $game_data")"
    done <<< "$(cat "$YAML" | yq '.games | keys')"

    echo $CONFIG | jq >| "$HOME/.config/sunshine/apps_linux.json"
}

function run-game {
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

    local WINE=$(cat "$YAML" | yq .runtime | expand)
    local PREFIXES=$(cat "$YAML" | yq .prefixes | expand)

    eval "$(cat "$YAML" | yq -o p '.env' | sed -r 's/([^ ]+) = (.*)/export \1="\2"/')" > /dev/null

    local DXVK="$(cat "$YAML" | yq ".games[\"$GAME\"].dxvk")"
    local VKD3D="$(cat "$YAML" | yq ".games[\"$GAME\"].vkd3d")"
    local PREFIX="$(cat "$YAML" | yq ".games[\"$GAME\"].prefix")"
    local GAME_DIR="$(cat "$YAML" | yq ".games[\"$GAME\"].dir")"
    local GAME_EXE="$(cat "$YAML" | yq ".games[\"$GAME\"].exe")"

    eval "$(cat "$YAML" | yq -o p ".games[\"$GAME\"].env" | sed -r 's/([^ ]+) = (.*)/export \1="\2"/')" > /dev/null

    export PATH="$WINE:$PATH"
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

    if [[ "$DXVK" != "false" ]] && ! (find "$WINEPREFIX/drive_c/windows/syswow64/" -name 'd3d11.dll.old' | grep -q .); then
        echo Installing dxvk...
        setup_dxvk install
    fi

    if [[ "$VKD3D" == "false" ]] && ! (find "$WINEPREFIX/drive_c/windows/syswow64/" -name 'd3d12.dll.old' | grep -q .); then
        echo Installing vkd3d...
        setup_vkd3d_proton install
    fi

    if ! find "$WINEPREFIX/drive_c/windows/syswow64/" -name 'nvapi.dll.old' | grep -q .; then
        echo Installing dxvk-nvapi...
        setup_dxvk_nvapi install
    fi

    # Enable nvidia DLSS 2.0
    if [ -f /usr/lib/nvidia/wine/nvngx.dll ]; then
        cp /usr/lib/nvidia/wine/nvngx.dll "$WINEPREFIX/drive_c/windows/system32/"
        cp /usr/lib/nvidia/wine/_nvngx.dll "$WINEPREFIX/drive_c/windows/system32/"
    fi

    # Enable CUDA for DLSS 3.0 or PhysX. This is taken from wine-staging
    if [ -f /usr/lib/wine/x86_64-windows/nvcuda.dll ]; then
        cp /usr/lib/wine/x86_64-windows/nvcuda.dll "$WINEPREFIX/drive_c/windows/system32/"
        cp /usr/lib32/wine/i386-windows/nvcuda.dll "$WINEPREFIX/drive_c/windows/syswow64/"
    fi

    echo "cd \"$GAME_DIR\""
    echo "export PATH=\"$WINE:\$PATH\""
    echo "export WINEPREFIX=\"$PREFIXES/$PREFIX\""
    echo '$WINE '\""$GAME_EXE"\" $(cat "$YAML" | yq ".games[\"$GAME\"].args // \"\"" | sed -r 's/- ([^ ]+)/\1/')

    cd "$GAME_DIR"
    gamemoderun mangohud wine "$GAME_EXE" ${@:2} $(cat "$YAML" | yq ".games[\"$GAME\"].args // \"\"" | sed -r 's/- ([^ ]+)/\1/')

    wineserver -k
}

sync-to-sunshine
run-game "$1" "${@:2}"