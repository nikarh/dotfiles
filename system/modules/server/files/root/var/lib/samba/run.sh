#!/bin/sh
set -e

cp /etc/samba/smb-base.conf /etc/samba/smb.conf

groupadd -g 1000 files || true;
useradd -MNo -u 1000 -g 1000 -s /usr/bin/nologin files || true;

# Create users
for f in /home/*; do
  username="$(basename $f)"
  useradd -MNo -u 1000 -g 1000 -s /usr/bin/nologin "$username" || true;
  usermod -p "*" "$username"
  echo -e "$username\n$username\n" | pdbedit -a "$username" -t
done

# Create personal shares
for f in /home/*/data; do
  username="$(basename $(dirname $f))"

  echo "[$username]" >> /etc/samba/smb.conf
  echo "  comment = $username's files" >> /etc/samba/smb.conf
  echo "  valid users = $username" >> /etc/samba/smb.conf
  echo "  path = /home/$username/data" >> /etc/samba/smb.conf
  echo "  writeable = yes" >> /etc/samba/smb.conf
done

# Create shared share
users="$(echo $(echo /home/*/shared | sed 's/ /\n/g' | xargs -I{} dirname {} | xargs -I{} basename {}))"
echo "[shared]" >> /etc/samba/smb.conf
echo "  comment = shared files" >> /etc/samba/smb.conf
echo "  valid users = $users" >> /etc/samba/smb.conf
echo "  path = /home/shield/shared" >> /etc/samba/smb.conf
echo "  writeable = no" >> /etc/samba/smb.conf
echo "  write list = $(echo $users | sed s/shield//)" >> /etc/samba/smb.conf

ionice -c 3 runsvdir -P /etc/runit