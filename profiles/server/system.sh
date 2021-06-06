#!/bin/bash -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

sudo timedatectl set-timezone Europe/Riga
sudo timedatectl set-ntp true

# Service users
sudo useradd -mUr -s /usr/bin/nologin -d /var/lib/navidrome navidrome 2> /dev/null || true;

pkg mdadm hdparm \
    haveged \
    docker fuse-overlayfs docker-compose \
    dhclient samba nginx certbot certbot-nginx \
    syncthing \
    filebrowser-bin navidrome-bin \
    cockpit cockpit-pcp \

add-user-to-groups docker

# Install homer
sudo mkdir -p /srv/http
if [[ ! -f "$HOME/.cache/homer.zip" ]]; then
    curl -s -fLo "$HOME/.cache/homer.zip" \
        --create-dirs "https://github.com/bastienwirtz/homer/releases/download/v21.03.2/homer.zip"
    sudo unzip "$HOME/.cache/homer.zip" -d /srv/http
fi
sudo chown -R http:http /srv/http

# Copy all configs to etc
sudo cp -ufrTv "$ROOT/system/etc/" /etc
sudo cp -ufrTv "$ROOT/system/srv/" /srv
sudo cp -ufrTv "$ROOT/system/var/" /var

sudo chown -R navidrome:navidrome /var/lib/navidrome
sudo chown -R files:files /var/lib/qbittorrent

# Append bind mounts
sudo mkdir -p /var/data
if ! grep -q '^# BEGIN Bind mounts$' /etc/pacman.conf; then
    sudo sed -i '/# BEGIN Bind mounts/,/# END Bind mounts/d' /etc/fstab
    # shellcheck disable=SC2002
    cat "$ROOT/system/fstab" | sudo tee -a /etc/fstab > /dev/null
fi

# Create files for nginx to start
if [[ ! -f /etc/letsencrypt/options-ssl-nginx.conf ]]; then
    sudo cp /usr/lib/python3.9/site-packages/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf
fi

# Create users for smb and per-user services
sudo groupadd -r -g 65533 shield 2> /dev/null || true;
sudo useradd -M -u 65533 -g 65533 -s /usr/bin/nologin shield 2> /dev/null || true;
sudo useradd -mU -s /usr/bin/nologin {nikarh,alyonovik} 2> /dev/null || true;
USER=nikarh add-user-to-groups
USER=alyonovik add-user-to-groups

# Filebrowser
sudo cp -ufrTv "$ROOT/users/nikarh/" /home/nikarh
sudo chown -R nikarh:nikarh /home/nikarh

# Add smb users
while read -r line || [ -n "$line" ]; do
    IFS=':' read -r username password <<< "$line"
    echo -e "$password\n$password\n" | sudo pdbedit -a "$username" -t > /dev/null
done < "$ROOT/system/smbusers"

sudo systemctl enable --now docker
enable-units dhclient@eno1 haveged-insecure sshd smb nmb systemd-timesyncd
enable-units \
    nginx cockpit.socket \
    navidrome filebrowser@nikarh syncthing@nikarh

# sftp server
sudo mkdir -p /srv/ftp/{tmp,{nikarh,alyonovik}/{tmp,data}}
sudo chown files:files /srv/ftp/{tmp,{nikarh,alyonovik}/{tmp,data,}}
sudo chmod 600 /etc/sftp/ssh*

sudo docker-compose --project-directory="$ROOT" up -d
