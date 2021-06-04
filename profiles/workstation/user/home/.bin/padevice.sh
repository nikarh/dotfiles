#!/usr/bin/env bash

SELECTED_COLOR="\033[1;32m"
FAINT_COLOR="\033[2m"
ENDCOLOR="\033[0m"

LIST_CMD=list-sinks
SELECT_CMD=set-default-sink

case $1 in
  sink|o|out|output|"")
    ;;
  source|i|in|input)
    LIST_CMD=list-sources
    SELECT_CMD=set-default-source
    ;;
  *)
    echo 'Invalid argument, provide either (source|i|in|input) or (sink|o|out|output)'
    exit 1
    ;;
esac


SELECTED=$(
    pacmd $LIST_CMD \
        | grep -e 'index:' -e 'name:' -e 'device.description = ' \
        | paste - - - \
        | sed -r 's/^\s+((\*)\s+)?/\2/g' \
        | awk '{
            name=$7; for(i=8;i<=NF;i++) {name=name" "$i}; 
            if ($1 == "*index:") printf "'$SELECTED_COLOR'";
            printf $2 ": " substr(name, 2, length(name)-2) " " "'$FAINT_COLOR'"$4"'$ENDCOLOR'" ;
            if ($1 == "*index:") printf "'$ENDCOLOR'";
            print ""
        }' \
        | fzf --ansi
)

if [ -z "$SELECTED" ]; then
    exit 1
fi

SELECTED_ID=$(echo $SELECTED | awk -F':' '{ print $1 }')
pacmd $SELECT_CMD "$SELECTED_ID"