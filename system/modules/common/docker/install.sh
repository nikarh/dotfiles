#!/bin/bash -e

function setup-docker-apt-repo {
    pkg ca-certificates curl gnupg

    sudo install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        curl -fsSL https://download.docker.com/linux/debian/gpg \
            | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    local arch
    arch="$(dpkg --print-architecture)"
    local codename
    codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
    if [[ -z "$codename" ]]; then
        codename="$(. /etc/os-release && echo "$UBUNTU_CODENAME")"
    fi
    if [[ -z "$codename" ]]; then
        echo "Unable to detect distro codename for Docker repo"
        exit 1
    fi

    cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${codename} stable
EOF
}

if command -v pacman > /dev/null 2>&1; then
    pkg docker docker-buildx docker-compose
elif command -v apt-get > /dev/null 2>&1; then
    setup-docker-apt-repo
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Unsupported distro: neither pacman nor apt-get found"
    exit 1
fi

if command -v pacman > /dev/null 2>&1 && [[ "$(pacman -Q nvidia nvidia-open nvidia-lts nvidia-dkms 2>/dev/null | wc -l )" -ne 0 ]]; then
    pkg nvidia-container-toolkit
fi

enable-unit "${ARGS_enable:-docker.service}"

if [ -n "$ARGS_insecure" ]; then
    add-user-to-groups docker
fi