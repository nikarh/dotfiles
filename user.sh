#!/usr/bin/env bash

set -e
ROOT=$(readlink -f "$(dirname "$0")")

function prepend() {
    awk "{print \"$1\" \$0}"
}

function section() {
    echo -e "\e[1m\e[34m$@\e[0m"
}

function git-get {
    if [ ! -d "$2" ]; then
        echo "Cloning $1 to $2"
        git clone -q "$1" "$2"
    else
        echo "Updating $1 in $2"
        git -C "$2" pull -q;
    fi
}

function file-get {
    echo "Downloading $1 to $2"
    curl -s -fLo "$2" --create-dirs "$1"
}

function install-code-extensions {
    local INSTALLED_EXTENSIONS=$(code --list-extensions)
    for EXTENSION in "$@"; do
        if ! echo $INSTALLED_EXTENSIONS | grep -qw $EXTENSION; then
            code --install-extension $EXTENSION;
        fi
    done
}

if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    echo "Generating ssh key..."
    ssh-keygen -C "${HOSTNAME}" -f "${HOME}/.ssh/id_rsa" -P "";
fi

section "Making everything makeable..."
find user/tools -name Makefile -execdir make "BIN=${ROOT}/user/home/.bin" \; | prepend '  '

section "Linking configs..."
cp -frsTv "${ROOT}/user/home/" ~ | prepend '  '

section "Adding stuff to autostart..."
mkdir -p ~/.config/autostart/

echo "
    insync
    pasystray
    nm-applet
    libinput-gestures
" | xargs -I{} ln -sf /usr/share/applications/{}.desktop ~/.config/autostart/

echo "
    redshift-gtk
    syncthing-gtk
" | xargs -I{} ln -sf ~/.local/share/applications/{}.desktop ~/.config/autostart/

cp /etc/xdg/autostart/gnome-keyring-{secrets,ssh}.desktop ~/.config/autostart/
sed -i '/^OnlyShowIn.*$$/d' ~/.config/autostart/gnome-keyring-{secrets,ssh}.desktop

systemctl enable --user syncthing

section "Downloading random stuff from the internet..."
git-get https://github.com/mrzool/bash-sensible.git \
    ~/.config/bash-sensible | prepend '  '
git-get https://github.com/tmux-plugins/tpm.git \
    ~/.config/tmux/plugins/tpm | prepend '  '
file-get https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    ~/.config/nvim/autoload/plug.vim | prepend '  '

section "Setting default gtk terminal to alacritty..."
gsettings set org.gnome.desktop.default-applications.terminal exec alacritty
gsettings set org.gnome.desktop.default-applications.terminal exec-arg -e

section "Setting xdg defaults..."
xdg-mime default Thunar.desktop inode/directory

ln -sfT ~/.config/Code ~/.config/Code\ -\ OSS

section "Installing vscode extensions..."
install-code-extensions \
    Rubymaniac.vscode-direnv \
    k--kato.intellij-idea-keybindings \
    PKief.material-icon-theme \
    fallenwood.vimL \
    golang.Go \
    ms-vscode.cpptools \
    redhat.vscode-yaml \
    mechatroner.rainbow-csv \
    yzhang.markdown-all-in-one \
    mads-hartmann.bash-ide-vscode \
    bmewburn.vscode-intelephense-client \
    naumovs.color-highlight \
    chrislajoie.vscode-modelines \
    | prepend '  '

section "Adding userChrome to firefox..."
# Firefox
[ -d ~/.mozilla/firefox/ ] && find ~/.mozilla/firefox/ -name '*.dev-edition-default' \
    -execdir mkdir -p {}/chrome \; \
    -execdir ln -sf ${ROOT}/user/firefox/userChrome.css {}/chrome/userChrome.css \;
