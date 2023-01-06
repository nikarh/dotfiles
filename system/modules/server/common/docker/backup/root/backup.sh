#!/bin/sh -xe

KEEP_BACKUPS=2
BUCKET="${BUCKET:-$HOSTNAME}"
SFTP_SERVER=files
SFTP_USER=backup
SFTP_ROOT=/data
VOLUMES=/volumes

function backup {
  local VOLUME="$1"
  local TARGET="$SFTP_ROOT/$BUCKET/$VOLUME"
  local DATE="$(date +"%FT%H-%M-%S")"

  if [ -z "$VOLUME" ]; then
    echo "Volume is required"
    exit 1
  fi

  local COMMANDS="$(tar -C "$VOLUMES/$VOLUME" -Jcf - . | \
    lftp -c "
      open -p 2222 -u \"$SFTP_USER,\" \"sftp://$SFTP_SERVER\";
      mkdir -pf \"$TARGET\";
      put /dev/stdin -o \"$TARGET/.$DATE.tar.xz.part\";
      mv \"$TARGET/.$DATE.tar.xz.part\" \"$TARGET/$DATE.tar.xz\";
      cls -1 --sort=name \"$TARGET\"
    " | \
    head -n "-$KEEP_BACKUPS" | \
    sed 's/^\(.*\)$/rm \1;/')"

  lftp -c "
    open -p 2222 -u \"$SFTP_USER,\" \"sftp://$SFTP_SERVER\";
    $COMMANDS
  "
}

function restore {
  local VOLUME="$1"
  local BUCKET="${2:-$BUCKET}"
  local SOURCE="$SFTP_ROOT/$BUCKET/$VOLUME"

  if [ -z "$VOLUME" ]; then
    echo "Volume is required"
    exit 1
  fi

  if [ ! -d "$VOLUMES/$VOLUME" ]; then
    echo "$VOLUME volume is not mounted"
    exit 1
  fi

  local LATEST=$(lftp -c "
    open -p 2222 -u \"$SFTP_USER,\" \"sftp://$SFTP_SERVER\";
    cls -1 --sort=name \"$SOURCE\"
  " | tail -n "1")

  if [ -z "$LATEST" ]; then
    echo "$VOLUME does not have backups in $BUCKET"
    exit 1
  fi

  local LATEST_FILENAME="$(basename -- "$LATEST")"

  lftp -c "
    open -p 2222 -u \"$SFTP_USER,\" \"sftp://$SFTP_SERVER\";
    get \"$LATEST\" -o \"$VOLUMES/$VOLUME-$LATEST_FILENAME\";
  "

  tar -C "$VOLUMES/$VOLUME" -Jxf "$VOLUMES/$VOLUME-$LATEST_FILENAME"
  rm "$VOLUMES/$VOLUME-$LATEST_FILENAME"
}

function backup_all {
  cd "$VOLUMES";
  for f in *; do
    if [ ! -d "$VOLUMES/$f" ]; then
      continue
    fi
    backup "$f"
  done;
}

function restore_all {
  cd "$VOLUMES";
  for f in *; do
    if [ ! -d "$VOLUMES/$f" ]; then
      continue
    fi
    restore "$f" "$1"
  done;
}

case "$1" in
  backup_all)
    backup_all;;
  restore_all)
    restore_all "$2";;
  backup)
    backup "$2";;
  restore)
    restore "$2" "$3";;
  *)
    echo "Unknown command";;
esac
