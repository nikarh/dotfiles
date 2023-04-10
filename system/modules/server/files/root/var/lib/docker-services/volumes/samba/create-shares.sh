#!/bin/sh

# Create personal shares
for f in /home/*/data; do
  username="$(basename $(dirname $f))"

  echo "[$username]"
  echo "  comment = $username's files"
  echo "  valid users = $username"
  echo "  path = /home/$username/data"
  echo "  writeable = yes"
done

# Create shared share
users="$(echo $(echo /home/*/shared | sed 's/ /\n/g' | xargs -I{} dirname {} | xargs -I{} basename {}))"
echo "[shared]"
echo "  comment = shared files"
echo "  valid users = $users"
echo "  path = /home/shield/shared"
echo "  writeable = no"
echo "  write list = $(echo $users | sed s/shield//)"
