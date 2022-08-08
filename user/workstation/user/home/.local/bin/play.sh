#!/usr/bin/env bash

cd "$(dirname "$(readlink -f "$0")")" || exit

function expand {
    cat - | sed -r "s:~:/home/$USER:g"
}

GAME="$1"
YAML="games.yaml"

WINE=$(cat "$YAML" | yq .runtime | expand)
PREFIXES=$(cat "$YAML" | yq .prefixes | expand)

eval "$(cat "$YAML" | yq -o p '.env' | sed -r 's/([^ ]+) = (.*)/export \1="\2"/')" > /dev/null

DXVK="$(cat "$YAML" | yq ".games[\"$GAME\"].dxvk")"
PREFIX="$(cat "$YAML" | yq ".games[\"$GAME\"].prefix")"
GAME_DIR="$(cat "$YAML" | yq ".games[\"$GAME\"].dir")"
GAME_EXE="$(cat "$YAML" | yq ".games[\"$GAME\"].exe")"


eval "$(cat "$YAML" | yq -o p ".games[\"$GAME\"].env" | sed -r 's/([^ ]+) = (.*)/export \1="\2"/')" > /dev/null

cd "$GAME_DIR"

echo "cd \"$GAME_DIR\""
echo "export WINE=\"$WINE\""
echo "export WINEPREFIX=\"$PREFIXES/$PREFIX\""
echo '$WINE '\""$GAME_EXE"\"

if [[ "$DXVK" == "true" ]]; then
    echo WINEPREFIX="$PREFIXES/$PREFIX" setup_dxvk install
fi

WINEPREFIX="$PREFIXES/$PREFIX" "$WINE" "$GAME_EXE"
