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
sudo cp -ufrTv "$ROOT/root/etc/" /etc
sudo cp -ufrTv "$ROOT/root/usr/" /usr
sudo cp -ufrTv "$ROOT/root/var/" /var

# TODO: Move to init container?
sudo chmod 600 /var/lib/docker-services/volumes/sftpd/secrets/ssh*

# Append bind mounts
sudo mkdir -p /var/data/{shares,home}
sudo mkdir -p /var/data/home/{backup/data,shield/shared,{nikarh,anastasiia}/{data,shared}}

# Fix permissions for PAM authentication
sudo chown files:files /var/data/shares/*
sudo chown files:files /var/data/home/*/*
sudo chmod 755 /var/data/home/*

# SSH authorized_keys for backup user
sudo cp -ufrTv "$ROOT/home/backup/" /var/data/home/backup/
sudo chmod -R go-rx /var/data/home/backup/.ssh
sudo chown -R files:files /var/data/home/backup/.ssh

sudo sed -i '/# BEGIN mounts/,/# END mounts/d' /etc/fstab
cat "$ROOT/root/fstab" | sudo tee -a /etc/fstab > /dev/null
sudo systemctl daemon-reload

# Start services
enable-service systemd-networkd
enable-service sshd
enable-service fancontrol
enable-service reduce-power-usage



docker network create services > /dev/null 2>&1 || true
find "$ROOT/docker/projects" -name '*.docker-compose.yaml' | while read -r file; do
    PROJECT_NAME="$(basename -- "$file" | cut -d'.' -f1)"
    echo "Starting containers for $PROJECT_NAME"
    docker-compose \
        --project-name="$PROJECT_NAME" \
        --project-directory="$ROOT" \
        --env-file="$ROOT/.env" \
        --file="$file" \
        up -d
done