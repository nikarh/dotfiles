#!/bin/bash -e

pkg hdparm fuse-overlayfs \
    btrfs-progs compsize parted \
    perl-rename \
    lm_sensors

# Required for eth
pkg polkit

if [[ "$(readlink -f /etc/systemd/system/mdmonitor.service)" != "/dev/null" ]]; then
    sudo systemctl mask mdmonitor
fi

# Copy all system configs
sudo cp -ufrT "$ROOT/root/etc/" /etc
sudo cp -ufrT "$ROOT/root/usr/" /usr
sudo cp -ufrT "$ROOT/root/var/" /var

# TODO: Move to init container?
sudo chmod 600 /var/lib/docker-services/volumes/sftpd/secrets/ssh*

# Create jellyfin transcode cache subvolume limited to 20gb
sudo mkdir -p /var/cache/jellyfin
sudo btrfs subvolume create /var/cache/jellyfin/transcodes 2> /dev/null || true
sudo btrfs quota enable /var/cache/jellyfin/transcodes
sudo btrfs qgroup limit 20G /var/cache/jellyfin/transcodes
sudo chown files:files /var/cache/jellyfin/transcodes

# Append bind mounts
sudo mkdir -p /var/smalldata
sudo mkdir -p /var/data/{shares,home}
sudo mkdir -p /var/data/home/{backups/data,shield/shared,{nikarh,anastasiia}/{data,shared}}
sudo mkdir -p /var/data/shares/tmp/Games

# Fix permissions for PAM authentication
sudo chown files:files /var/data/shares/*
sudo chown files:files /var/data/home/*/*
sudo chown files:files /var/smalldata
sudo chown files:files /var/data/shares/tmp/Games
sudo chmod 755 /var/data/home/*

# SSH authorized_keys for backups user
sudo cp -ufrT "$ROOT/home/backups/" /var/data/home/backups/
sudo chmod -R go-rx /var/data/home/backups/.ssh
sudo chown -R files:files /var/data/home/backups/.ssh

sudo sed -i '/# BEGIN mounts/,/# END mounts/d' /etc/fstab
cat "$ROOT/root/fstab" | sudo tee -a /etc/fstab > /dev/null
sudo systemctl daemon-reload

# Start services
enable-unit systemd-networkd
enable-unit sshd
enable-unit fancontrol
enable-unit reduce-power-usage

DOCKER_NIC="$(ip --json link | jq -r '([.[].ifname | select(. | startswith("br-"))][0])')"
sed "s/DOCKER_NIC=.*/DOCKER_NIC=${DOCKER_NIC}/g" "$ROOT/.env.default" > "$ROOT/.env.new"
if ! diff -q "$ROOT/.env.new" "$ROOT/.env" > /dev/null 2>&1; then
    echo "Moving env"
    mv "$ROOT/.env.new" "$ROOT/.env"
fi

docker-compose \
    --project-directory="$ROOT" \
    --env-file="$ROOT/.env" \
    $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
    up -d
