#!/bin/bash -e

pkg mdadm hdparm fuse-overlayfs dhclient \
    btrfs-progs parted \
    libva-headless ffmpeg-headless \
    perl-rename \
    lm_sensors \
    polkit `# required to reconnect to eth`

sudo systemctl mask mdmonitor

# Copy all configs to etc
sudo cp -ufrTv "$ROOT/root/etc/" /etc
sudo cp -ufrTv "$ROOT/root/usr/" /usr
sudo cp -ufrTv "$ROOT/root/var/" /var

sudo chown -R 1000:1000 /var/lib/{qbittorrent,filebrowser,netdata,homer,jellyfin,radarr,prowlarr,bazarr}
sudo chmod 600 /var/lib/sftpd/secrets/ssh*

# Append bind mounts
sudo mkdir -p /var/data/{shares,home}
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
sudo systemctl enable systemd-networkd
sudo systemctl enable sshd
sudo systemctl enable fancontrol
sudo systemctl enable reduce-power-usage

docker-compose --project-directory="$ROOT" \
    --env-file "$ROOT/.env" \
    build
docker-compose --project-directory="$ROOT" \
    --env-file "$ROOT/.env" \
    -f "$ROOT/docker-compose.yaml" \
    -f "$ROOT/../common/docker-compose.yaml" \
    up -d
