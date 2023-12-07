#!/bin/sh
# bash <(curl -sL https://raw.github.com/nikarh/dotfiles/main/scripts/init.sh)

HOSTNAME=
while ! [[ "$HOSTNAME" =~ ^[a-z0-9-]+$ ]]; do
   echo -n "Enter hostname: "
   read HOSTNAME
done
export HOSTNAME
function initialize_root {
  hostnamectl set-hostname "$HOSTNAME"

  echo "Installing packages"
  if command -v pacman &> /dev/null; then
    pacman-key --init
    pacman-key --populate archlinuxarm
    pacman -Syu
    pacman --noconfirm -S --needed git git-crypt jq sudo croc direnv
  elif command -v apk &> /dev/null; then
    apk update
    apk upgrade
    apk add git git-crypt jq sudo croc direnv
  fi

  echo "Setting up sudo"
  if ! echo "$(cut -d: -f1 /etc/group)" | grep -qw sudo; then
      groupadd sudo
  fi

  if ! groups "$MAIN_USER" | grep -qw sudo; then
      gpasswd -a "$MAIN_USER" sudo
  fi

  echo "%sudo ALL=(ALL) ALL" > /etc/sudoers.d/sudo
}

function intialize_user {
  if [ ! -f ~/.ssh/id_rsa ]; then
    echo
    echo "Generating ssh key"
    ssh-keygen -C "$HOSTNAME" -f "$HOME/.ssh/id_rsa" -P ""
  fi

  if [ ! -f ~/.ssh/authorized_keys ]; then
    echo
    echo "Adding default authorized key for ssh"
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+MGmNM8GaaPkY3x6vGGzqVroifptnTnKdcX+x124UM4ntv+Lrkj0lBmLz4aRnabpRIBHP3zVB1BgfES3qBUWGU+CyYCRthwemc5vzisUDcch+LKHDigLcpQtCzuN2vR9OzL13hWcyMJ0rRX7r1A/0Q5qH3nuk45vmSA9y1JB6jpb7D+Q0X77etHGFwJuePT/fp33+9i6GS0Vpwbk+Yw951pbb8itMqJNhWc6OOspYqXyWI2K+QSe3DifSdFtuCv7+i9P+zuq2iberBKzpOPFV3q46kSzDO0LFVpZ8420Ah7yebwMz8OJ+DTR9N34yEIjC1TW8NHUoy5m9UcDaMQMQSX286O2Q+/cv+U+Ud9dtOltZ1vaalHTajJCPbtTF9v2cEeLUBjm7CMJTcN1cS7g6bDjaSt/qndXdgOoyYm1w9Fj8FNTWsyU2UdVftj5ur8WIs+wBs7+yIPbUOsCURcos9w8/2djXDUCqjoYN43po3uYkzzyHT5eFhD5E8litFWc= nikarh@home" > ~/.ssh/authorized_keys
  fi

  if [ "$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | wc -l)" -eq 0 ]; then
    echo
    echo "Generating gpg key"
    export GPG_TTY=$(tty)
    GPG_ID=$(gpg --batch --gen-key <<EOF 2>&1 | sed -rn 's/.*\/([A-Z0-9]+)\.rev.*/\1/p'
%no-protection
Key-Type: 1
Key-Length: 2048
Subkey-Type: 1
Subkey-Length: 2048
Name-Real: $HOSTNAME
Name-Email: n@arhipov.net
Expire-Date: 0
EOF
  )
    echo
    echo "Download PGP key to the main computer"
    gpg --export --armor "$GPG_ID" > $GPG_ID.pub.gpg
    croc $GPG_ID.pub.gpg
    rm $GPG_ID.pub.gpg

    echo
    echo "Import key in dotfiles on the main computer and press enter when done"
    echo gpg --import $GPG_ID.pub.gpg
    echo rm $GPG_ID.pub.gpg
    echo git-crypt add-gpg-user --trusted $GPG_ID
    echo git push
    read 
  fi

  git clone --recursive https://github.com/nikarh/dotfiles.git
  cd dotfiles
  git-crypt unlock

  echo "export PROFILE=$HOSTNAME" > .envrc
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
  eval "$(direnv hook bash)"
  direnv allow
}

MAIN_USER=
if [[ "$USER" == "root" ]]; then 
  while ! [[ "$MAIN_USER" =~ ^[a-z]+$ ]]; do
    echo -n "Enter username: "
    read MAIN_USER
  done

  initialize_root

  echo "Creating user $MAIN_USER."
  if ! getent passwd "$MAIN_USER" > /dev/null; then
      useradd -m "$MAIN_USER"
      passwd "$MAIN_USER"
  fi

  export -f initialize_user
  su "$MAIN_USER" -c "initialize_user"
else
  echo "Initializing, enter root password."
  export MAIN_USER="$USER"
  export -f initialize_root
  su root -c "initialize_root"

  intialize_user
fi
