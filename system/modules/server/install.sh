#!/bin/bash -e

pkg mdadm hdparm fuse-overlayfs dhclient

sudo systemctl mask mdmonitor

# Copy all configs to etc
sudo cp -ufrTv "$ROOT/root/etc/" /etc

if [[ "$COPY_VAR" == "true" ]]; then
    sudo cp -ufrTv "$ROOT/root/var/" /var
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
cat "$ROOT/root/fstab" | sudo tee -a /etc/fstab > /dev/null
sudo systemctl daemon-reload
sudo mount -a

# Start services
sudo systemctl enable dhclient@eno1
sudo systemctl enablesshd

sudo docker-compose --project-directory="$ROOT" build
sudo docker-compose --project-directory="$ROOT" up -d
