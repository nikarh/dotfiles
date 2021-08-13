#!/bin/bash -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

sudo timedatectl set-timezone Europe/Riga
sudo timedatectl set-ntp true

pkg mdadm hdparm \
    haveged \
    docker fuse-overlayfs docker-compose \
    dhclient samba nginx \
    certbot certbot-nginx certbot-systemd \
    netdata

sudo systemctl mask mdmonitor

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

if [[ "$COPY_VAR" == "true" ]]; then
    sudo cp -ufrTv "$ROOT/system/var/" /var
fi

sudo chown -R files:files /var/lib/{qbittorrent,filebrowser,navidrome}
sudo chmod 600 /etc/sftp/ssh*

# Append bind mounts
sudo mkdir -p /var/data
if ! grep -q '^# BEGIN mounts$' /etc/pacman.conf; then
    sudo sed -i '/# BEGIN mounts/,/# END mounts/d' /etc/fstab
    # shellcheck disable=SC2002
    cat "$ROOT/system/fstab" | sudo tee -a /etc/fstab > /dev/null
fi

# Create files for nginx to start
if [[ ! -f /etc/letsencrypt/options-ssl-nginx.conf ]]; then
    sudo cp /usr/lib/python3.9/site-packages/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf
fi

# Create users for smb
sudo groupadd -r -g 65533 shield 2> /dev/null || true;
sudo useradd -M -u 65533 -g 65533 -s /usr/bin/nologin shield 2> /dev/null || true;
sudo useradd -MU -s /usr/bin/nologin {nikarh,alyonovik} 2> /dev/null || true;

# Add smb users
while read -r line || [ -n "$line" ]; do
    IFS=':' read -r username password <<< "$line"
    echo -e "$password\n$password\n" | sudo pdbedit -a "$username" -t > /dev/null
done < "$ROOT/system/smbusers"

sudo systemctl enable --now docker
enable-units \
    dhclient@eno1 systemd-timesyncd sshd smb nmb \
    nginx \
    netdata

sudo docker-compose --project-directory="$ROOT" up -d
