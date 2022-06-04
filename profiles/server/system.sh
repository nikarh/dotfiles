#!/bin/bash -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

sudo timedatectl set-timezone Europe/Riga
sudo timedatectl set-ntp true

pkg mdadm hdparm docker fuse-overlayfs docker-compose dhclient

sudo systemctl mask mdmonitor

add-user-to-groups docker

# Copy all configs to etc
sudo cp -ufrTv "$ROOT/system/etc/" /etc

if [[ "$COPY_VAR" == "true" ]]; then
    sudo cp -ufrTv "$ROOT/system/var/" /var
fi

sudo chown -R files:files /var/lib/{qbittorrent,filebrowser,traefik,netdata,authelia,homer,jellyfin,radarr,jackett,bazarr}
sudo chmod 600 /var/lib/sftpd/secrets/ssh*

# Append bind mounts
sudo mkdir -p /var/data/{shares,home}
mkdir -p /var/data/shares/tmp/ssd
sudo mkdir -p /var/data/home/{shield/shared,{nikarh,anastasiia}/{data,shared}}

# Fix permissions for PAM authentication
sudo chown files:files /var/data/shares/*
sudo chown files:files /var/data/home/*/*
sudo chmod 755 /var/data/home/*

sudo sed -i '/# BEGIN mounts/,/# END mounts/d' /etc/fstab
cat "$ROOT/system/fstab" | sudo tee -a /etc/fstab > /dev/null
sudo systemctl daemon-reload
sudo mount -a

# Start services
sudo systemctl enable --now docker
enable-units \
    dhclient@eno1 systemd-timesyncd sshd

sudo docker-compose --project-directory="$ROOT" build
sudo docker-compose --project-directory="$ROOT" up -d
