#!/usr/bin/bash -ex

cd "$(dirname "$(readlink -f "$0")")" || exit

function expand {
    cat - | sed -r "s:~:/home/$USER:g"
}

YQ="yq"
YAML="/srv/games/.config/games.yaml"

PREFIXES="$(cat "$YAML" | "$YQ" '.paths.prefixes' | expand)"
RUNTIMES="$(cat "$YAML" | "$YQ" '.paths.runtimes' | expand)"
LIBRARIES="$(cat "$YAML" | "$YQ" '.paths.libraries' | expand)"
CACHE="$(cat "$YAML" | "$YQ" '.paths.cache' | expand)"
SHELLS="$(cat "$YAML" | "$YQ" '.paths.shells' | expand)"
SGDB_TOKEN="$(cat "$(cat "$YAML" | "$YQ" '.paths.steamgriddb_key')" || echo)"

function file-get {
    curl -s -fLo "$2" --create-dirs "$1"
}

function release {
    local version="$2"
    local res=$(curl -s "https://api.github.com/repos/$1/releases/$([[ "$2" != "latest" ]] && echo "tag/")$2")

    echo $(echo "$res" | jq -r '.tag_name')
    echo $(echo "$res" | jq -r '.assets[].browser_download_url' | grep "$3" | head -n 1)
}

function untar {
    mkdir -p "$2"
    tar --strip-components=1 -xf "$1" -C "$2" && rm "$1"
}

function get-steamgriddb-id {
    mkdir -p "$CACHE"
    touch "$CACHE/steamgriddb_ids.json"

    if [[ "$(cat "$YAML" | "$YQ" ".games[\"$1\"].steamgriddb")" == "false" ]]; then
        return
    fi

    # Try to extract from games.yaml
    local id="$(cat "$YAML" | "$YQ" ".games[\"$1\"].steamgriddb_id // \"\"")"
    if [ -n "$id" ]; then
        echo "$id";
        return
    fi

    # Try to extract from cache
    local name="$(cat "$YAML" | "$YQ" ".games[\"$1\"].name")"
    local ids="$(cat "$CACHE/steamgriddb_ids.json" || echo {})"
    if [ -z "$ids" ]; then
        ids="{}"
    fi

    local id="$(echo "$ids" | jq -r ".\"$name\" // \"\"")"
    if [ -n "$id" ]; then
        echo "$id";
        return
    fi

    # Try to find in steamgriddb and cache it
    local steamgridb_id="$(curl -s -H "Authorization: Bearer $SGDB_TOKEN" \
        "https://www.steamgriddb.com/api/v2/search/autocomplete/$(printf %s "$1" | jq -s -R -r @uri)" \
        | jq -r '.data[0].id // ""')"

    echo "$ids" | jq --arg id "$steamgridb_id" ". + {\"$name\": \$id}" >| "$CACHE/steamgriddb_ids.json"
    echo "$steamgridb_id"
}

function install-release {
    mkdir -p "$4"
    if [ -d "$4/$2" ]; then
        return;
    fi

    local release="$(release "$1" "$2" "$3")"
    local version=$(echo "$release" | sed -n 1p)
    local url="$(echo "$release" | sed -n 2p)"
    local path="$4/${url##*/}"

    echo Downloading "$1 $2 ($version)"
    file-get "$url" "$path"
    untar "$path" "$4/$version"

    if [[ "$2" == "latest" ]]; then
        ln -sf "$4/$version" "$4/latest"
    fi

}

function prepare-runtime {
    install-release GloriousEggroll/wine-ge-custom "$1" "\.tar\.xz$" "$RUNTIMES"
}

function prepare-library {
    local version="$(cat "$YAML" | "$YQ" ".libraries[\"$1\"] // \"\"")"
    if [ -n "$version" ]; then
        install-release "$2" "$version" "$3" "$LIBRARIES/$1"

        if [ -n "$4" ] && ! [ -f "$LIBRARIES"/$1/$version/setup_$1.sh ]; then
            file-get "$4" "$LIBRARIES"/$1/$version/setup_$1.sh
        fi
    fi
}

function prepare-libaries {
    mkdir -p "$LIBRARIES"
    mkdir -p "$LIBRARIES/dxvk-nvapi"

    prepare-library dxvk         doitsujin/dxvk                 ".*\.tar\.gz$" "https://aur.archlinux.org/cgit/aur.git/plain/setup_dxvk.sh?h=dxvk-bin"
    prepare-library dxvk-async   Sporif/dxvk-async              ".*\.tar\.gz$"
    prepare-library dxvk-nvapi   jp7677/dxvk-nvapi              ".*\.tar\.gz$" "https://aur.archlinux.org/cgit/aur.git/plain/setup_dxvk_nvapi.sh?h=dxvk-nvapi-mingw"
    prepare-library vkd3d-proton HansKristian-Work/vkd3d-proton ".*\.tar\.zst$"

    chmod +x "$LIBRARIES"/*/*/*.sh
}

function prepare-winetricks {
    mkdir -p "$RUNTIMES/.bin/"
    if ! [ -f "$RUNTIMES/.bin/winetricks" ]; then
        file-get "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" "$RUNTIMES/.bin/winetricks"
        chmod +x "$RUNTIMES/.bin/winetricks"
    fi

    if ! [ -f "$RUNTIMES/.bin/cabextract" ]; then
        file-get "https://archlinux.org/packages/community/x86_64/cabextract/download/" "$RUNTIMES/cabextract.tar.zst"
        tar --extract -C "$RUNTIMES/.bin" -f "$RUNTIMES/cabextract.tar.zst" usr/bin/cabextract --strip-components 2
        rm "$RUNTIMES/cabextract.tar.zst"
    fi
}

# For streaming to TV
function sync-to-sunshine {
    local BANNERS="$CACHE/banners"
    mkdir -p "$HOME/.config/sunshine"
    mkdir -p "$BANNERS"

    local CONFIG='{"env": {"PATH": "$(PATH):$(HOME)\/.local\/bin"}, "apps": []}'

    while read game; do
        local game_id="$(get-steamgriddb-id "$game")"

        if [[ "$(cat "$YAML" | "$YQ" ".games[\"$game\"].sunshine")" == "false" ]]; then
            continue
        fi

        if [[ "$(cat "$YAML" | "$YQ" ".games[\"$game\"].steamgriddb")" == "false" ]]; then
            continue
        fi

        local game_data="$(jq --null-input \
            --arg name "$(cat "$YAML" | "$YQ" ".games[\"$game\"].name")" \
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
    done <<< "$(cat "$YAML" | "$YQ" '.games[] | key')"

    echo $CONFIG | jq >| "$HOME/.config/sunshine/apps_linux.json"
}

# For easy launching
function create-desktop-files {
    local ICONS="$CACHE/icons"
    local APPS="$HOME/.local/share/applications/gamesh"
    mkdir -p "$ICONS"

    rm -f "$APPS"/*
    mkdir -p "$APPS"

    while read game; do
        local game_id="$(get-steamgriddb-id "$game")"

        if [[ "$(cat "$YAML" | "$YQ" ".games[\"$game\"].desktop")" == "false" ]]; then
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
            "Name=$(cat "$YAML" | "$YQ" ".games[\"$game\"].name")" \
            "Path=$(dirname "$(realpath "$0")")" \
            "Exec=$(realpath "$0") $game" \
            "Icon=$ICONS/$game_id.png" \
            "Terminal=false" \
            "Categories=Games;" > "$APPS/$game.desktop"

    done <<< "$(cat "$YAML" | "$YQ" '.games[] | key')"
}

# For https://github.com/SteamGridDB/steam-rom-manager
function create-shell-scripts {
    rm -rf "$SHELLS_DIR"
    mkdir -p "$SHELLS_DIR"

    while read line; do
        local name="$(cat "$YAML" | "$YQ" ".games[\"$game\"].name")"

        echo -e "#!/bin/bash\n$HOME/.bin/play.sh $game" > "$SHELLS_DIR/$name.sh"
        chmod +x "$SHELLS_DIR/$name.sh"
    done <<< "$(cat "$YAML" | "$YQ" '.games[] | key')"
}

function run-wine {
    local GAME="$1"

    local RUNTIME=$(cat "$YAML" | "$YQ" '.runtime // "latest"')
    local WINE="$RUNTIMES/$RUNTIME"

    prepare-runtime
    prepare-libaries

    eval "$(cat "$YAML" | "$YQ" -o p '.env' | sed -r 's/([^ ]+) = (.*)/export \1="\2"/')" > /dev/null

    local PREFIX="$(cat "$YAML" | "$YQ" ".games[\"$GAME\"].prefix")"
    local GAME_DIR="$(cat "$YAML" | "$YQ" ".games[\"$GAME\"].dir")"
    local GAME_EXE="$(cat "$YAML" | "$YQ" ".games[\"$GAME\"].run")"

    eval "$(cat "$YAML" | "$YQ" -o p ".games[\"$GAME\"].env" | sed -r 's/([^ ]+) = (.*)/export \1="\2"/')" > /dev/null

    export PATH="$WINE/bin:$PATH"
    export WINEPREFIX="$PREFIXES/$PREFIX"

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

    # Winetricks
    while read line; do
        if [ -z "$line" ]; then continue; fi
        if ! grep -Fxq "$line" "$WINEPREFIX/.winetricks"; then
            winetricks $line
            echo "$line" >> "$WINEPREFIX/.winetricks"
        fi
    done <<< "$(cat "$YAML" | $YQ ".games[\"$GAME\"].winetricks[]")"

    # Mounts
    while read line; do
        local from="$(cat "$YAML" | $YQ ".games[\"$GAME\"].mounts[\"$line\"]")"
        ln -sf "$from" "$WINEPREFIX/dosdevices/${line}:"
    done <<< "$(cat "$YAML" | $YQ '.games["'"$GAME"'"].mounts[] | key')"

    # Install libraries for games
    local system32="$WINEPREFIX/drive_c/windows/system32"

    while read line; do
        local version="$(cat "$YAML" | "$YQ" ".libraries[\"$line\"]")"
        local dll="$(find "$LIBRARIES/$line/$version/x64" -name "*.dll" | head -n 1)"
        
        if ! diff -q "$system32/${dll##*/}" "$dll"; then
            echo Installing $line...
            find "$LIBRARIES/$line/$version/" -maxdepth 1 -name "*.sh" -type f -exec {} install \;
        fi
    done <<< "$(cat "$YAML" | $YQ '.libraries[] | key')"

    # Enable nvidia DLSS 2.0, this comes with nvidia-utils
    if [ -f /usr/lib/nvidia/wine/nvngx.dll ]; then
        echo Copying ngngx.dll
        cp /usr/lib/nvidia/wine/nvngx.dll "$WINEPREFIX/drive_c/windows/system32/"
        cp /usr/lib/nvidia/wine/_nvngx.dll "$WINEPREFIX/drive_c/windows/system32/"
    fi

    # Enable CUDA for DLSS 3.0 or PhysX. This is taken from wine
    if [ -f "$LIBRARIES/nvcuda/nvcuda64.dll" ]; then
        echo Copying nvcuda
        cp "$LIBRARIES/nvcuda/nvcuda64.dll" "$WINEPREFIX/drive_c/windows/system32/nvcuda.dll"
        cp "$LIBRARIES/nvcuda/nvcuda32.dll" "$WINEPREFIX/drive_c/windows/syswow64/nvcuda.dll"
    fi

    wineserver --wait

    cd "$GAME_DIR"
    gamemoderun mangohud wine "$GAME_EXE" ${@:2} $(cat "$YAML" | "$YQ" ".games[\"$GAME\"].args[]")

    if [[ "$(cat "$YAML" | $YQ ".games[\"$GAME\"].cleanup")" != "false" ]]; then
        wineserver -k
    fi
}

function run-native {
    local GAME="$1"
    local RUN="$(cat "$YAML" | "$YQ" ".games[\"$GAME\"].run")"
    local GAME_DIR="$(cat "$YAML" | $YQ ".games[\"$GAME\"].dir // \"$HOME\"")"

    cd "$GAME_DIR"
    "$RUN" $(cat "$YAML" | "$YQ" ".games[\"$GAME\"].args[]")
}

function run {
    local GAME="$1"

    if [ -z "$GAME" ]; then
        echo Provide game key as an argument:
        echo "$(cat "$YAML" | "$YQ" '.games[] | key')"
        exit 1;
    fi

    if [[ "$(cat "$YAML" | "$YQ" ".games[\"$GAME\"]")" == "null" ]]; then
        echo Invalid game "$GAME", provide valid game key as an argument:
        echo "$(cat "$YAML" | "$YQ" '.games[] | key')"
        exit 1;
    fi

    local TYPE="$(cat "$YAML" | "$YQ" ".games[\"$GAME\"].type // \"wine\"")"

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
        if [[ "$(cat "$YAML" | "$YQ" '.generate.sunshine')" == "true" ]]; then
            sync-to-sunshine
        fi
        if [[ "$(cat "$YAML" | "$YQ" '.generate.desktop')" == "true" ]]; then
            create-desktop-files
        fi
        if [[ "$(cat "$YAML" | "$YQ" '.generate.shell')" == "true" ]]; then
            create-shell-scripts
        fi
        sha1sum "$YAML" >| "$YAML.sha1"
    fi
}

refresh

if [ "$1" == "watch" ]; then
    while inotifywait -e modify "$YAML"; do
        echo "Refreshing generated files"
        refresh;
    done
else
    run "$1" "${@:2}"
fi
