#!/bin/sh

if ! which jq >/dev/null; then
  if which apk >/dev/null; then
    apk add --no-cache jq curl
  else
    apt-get update -y
    apt-get install -y curl jq
    rm -rf /var/lib/apt/lists
  fi
fi

rm -f /etc/sftp/users.conf
mkdir -p /etc/sftp

for f in /home/*; do
  echo "$(basename $f):stub:1000:1000" >> /etc/sftp/users.conf;
done

/entrypoint
