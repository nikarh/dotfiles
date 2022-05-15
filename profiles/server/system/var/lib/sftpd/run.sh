#!/bin/sh

if ! which jq >/dev/null; then
  apk add --no-cache jq curl
fi

rm -f /etc/sftp/users.conf
mkdir -p /etc/sftp

for f in /home/*; do
  echo "$(basename $f)::1000:1000" >> /etc/sftp/users.conf;
done

/entrypoint
