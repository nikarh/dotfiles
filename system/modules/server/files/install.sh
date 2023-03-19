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

DOCKER_NIC="$(ip --json link | jq -r '(.[].ifname|select(. | startswith("br-"))) // "undefined"')"

docker-compose \
    --project-directory="$ROOT" \
    --env-file="$ROOT/.env" \
    -e "DOCKER_NIC=$DOCKER_NIC" \
    $(find "$ROOT/docker/projects" -name '*.docker-compose.yaml' -exec echo -f {} \;) \
    up -d