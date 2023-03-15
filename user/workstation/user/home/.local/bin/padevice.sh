#!/usr/bin/env bash

LIST_CMD="list sinks"
SELECT_CMD=set-default-sink
SELECTED_CMD="get-default-sink"
PROMPT=Output

case $1 in
  sink|o|out|output|"")
    ;;
  source|i|in|input)
    LIST_CMD="list sources"
    SELECT_CMD=set-default-source
    SELECTED_CMD="get-default-source"
    PROMPT=Input
    ;;
  *)
    echo 'Invalid argument, provide either (source|i|in|input) or (sink|o|out|output)'
    exit 1
    ;;
esac

if test -t 0; then
  SELECTED_COLOR="\033[1;32m"
  FAINT_COLOR="\033[2m"
  ENDCOLOR="\033[0m"
  DMENU="fzf --ansi"
else
  SELECTED_COLOR='<span weight=\"bold\">'
  FAINT_COLOR='<span foreground=\"gray\">'
  ENDCOLOR='</span>'
  DMENU="rofi -dmenu -markup-rows -i -no-custom -p $PROMPT"
fi

CURRENT="$(pactl $SELECTED_CMD)"

SELECTED=$(
    pactl $LIST_CMD \
        | grep -e 'Name:' -e 'Description: ' \
        | paste - - \
        | sed -r 's/^\s+((\*)\s+)?/\2/g' \
        | awk '{
            name=$4; for(i=5;i<=NF;i++) {name=name" "$i}; 
            if ($2 == "'"$CURRENT"'") printf "'"$SELECTED_COLOR"'";
            printf name " " "'"$FAINT_COLOR"'"$2"'"$ENDCOLOR"'" ;
            if ($2 == "'"$CURRENT"'") printf "'"$ENDCOLOR"'";
            print ""
        }' \
        | $DMENU
)

if [ -z "$SELECTED" ]; then
    exit 1
fi

SELECTED_ID=$(echo "$SELECTED" | awk -F' ' '{ print $NF }' | sed -r 's/([^>]*>){0,1}([^<]*)(<.*$){0,1}/\2/g')

pactl $SELECT_CMD "$SELECTED_ID"