#!/bin/bash -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

sudo timedatectl set-timezone Europe/Riga
sudo timedatectl set-ntp true

pkg mdadm hdparm \
    haveged \
    docker fuse-overlayfs docker-compose \
    dhclient samba \
    certbot certbot-systemd

sudo systemctl mask mdmonitor

add-user-to-groups docker

# Copy all configs to etc
sudo cp -ufrTv "$ROOT/system/etc/" /etc

if [[ "$COPY_VAR" == "true" ]]; then
    sudo cp -ufrTv "$ROOT/system/var/" /var
fi

sudo chown -R files:files /var/lib/{qbittorrent,filebrowser,traefik,netdata,authelia,homer,jellyfin}
sudo chmod 600 /var/lib/sftpd/secrets/ssh*

# Append bind mounts
sudo mkdir -p /var/data
if ! grep -q '^# BEGIN mounts$' /etc/pacman.conf; then
    sudo sed -i '/# BEGIN mounts/,/# END mounts/d' /etc/fstab
    # shellcheck disable=SC2002
    cat "$ROOT/system/fstab" | sudo tee -a /etc/fstab > /dev/null
fi

# Create users for smb
sudo groupadd -r -g 65533 shield 2> /dev/null || true;
sudo useradd -M -u 65533 -g 65533 -s /usr/bin/nologin shield 2> /dev/null || true;
sudo useradd -MU -s /usr/bin/nologin {nikarh,anastasiia} 2> /dev/null || true;

# Add smb users
while read -r line || [ -n "$line" ]; do
    IFS=':' read -r username password <<< "$line"
    echo -e "$password\n$password\n" | sudo pdbedit -a "$username" -t > /dev/null
done < "$ROOT/system/smbusers"

sudo systemctl enable --now docker
enable-units \
    dhclient@eno1 systemd-timesyncd sshd smb nmb

sudo docker-compose --project-directory="$ROOT" up -d
