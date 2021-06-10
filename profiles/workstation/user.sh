#!/bin/bash -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

section "Making everything makeable..."
find $(ROOT)/user/tools -name Makefile -execdir make "BIN=$ROOT/user/home/.bin" \; | prepend '  '

section "Linking configs..."
cp -frsTv "$ROOT/user/home/" ~ | prepend '  '

section "Adding stuff to autostart..."
mkdir -p ~/.config/autostart/

TO=~/.config/autostart/ FROM=/usr/share/applications/ ln-all \
    insync \
    pasystray \
    nm-applet

TO=~/.config/autostart/ FROM=~/.local/share/applications/ ln-all \
    alacritty \
    cbatticon \
    redshift-gtk \
    syncthing-gtk

systemctl enable --user syncthing
# Unfortunately, sleep hooks are not working with user-level services
sudo systemctl enable "locker@$USER.service"

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
# glib hardcodes terminals https://github.com/GNOME/glib/blob/master/gio/gdesktopappinfo.c#L2581
ln -sf /usr/bin/alacritty ~/.bin/xterm

section "Setting xdg defaults..."
xdg-mime default thunar.desktop inode/directory

ln -sfT ~/.config/Code ~/.config/Code\ -\ OSS

section "Installing vscode extensions..."
install-code-extensions \
    Rubymaniac.vscode-direnv \
    k--kato.intellij-idea-keybindings \
    PKief.material-icon-theme \
    fallenwood.vimL \
    golang.go \
    ms-vscode.cpptools \
    redhat.vscode-yaml \
    mechatroner.rainbow-csv \
    yzhang.markdown-all-in-one \
    mads-hartmann.bash-ide-vscode \
    bmewburn.vscode-intelephense-client \
    naumovs.color-highlight \
    chrislajoie.vscode-modelines \
    zhuangtongfa.material-theme \
    | prepend '  '

section "Adding userChrome to firefox..."
# Firefox
[ -d ~/.mozilla/firefox/ ] && find ~/.mozilla/firefox -maxdepth 1 -type d \( -name '*dev-edition-default' -o -name '*default-release' \) \
    -execdir mkdir -p {}/chrome \; \
    -execdir ln -sf "$ROOT/user/firefox/userChrome.css" {}/chrome/userChrome.css \;
