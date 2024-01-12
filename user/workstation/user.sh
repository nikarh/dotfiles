#!/usr/bin/env bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

section "Making everything makeable..."
find -L "$ROOT/user/tools" -name Makefile -execdir make "BIN=$ROOT/user/home/.local/bin" \; | prepend '  '

section "Linking configs..."
cp -frsTv "$ROOT/user/home/" ~ | prepend '  '

source "$ROOT/user/home/.profile"

systemctl enable --user syncthing
systemctl enable --user sunshine
systemctl enable --user ssh-agent

section "Downloading random stuff from the internet..."
git-get https://github.com/mrzool/bash-sensible.git \
    ~/.config/bash-sensible | prepend '  '
git-get https://github.com/tmux-plugins/tpm.git \
    ~/.config/tmux/plugins/tpm | prepend '  '
file-get https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    ~/.config/nvim/autoload/plug.vim | prepend '  '

section "Updating vim plugins..."
nvim +PlugClean! +PlugUpdate +qa > /dev/null 2>&1

section "Setting default gtk terminal to alacritty..."
gsettings set org.gnome.desktop.default-applications.terminal exec alacritty
gsettings set org.gnome.desktop.default-applications.terminal exec-arg -e
gsettings set org.gnome.desktop.interface font-name "Noto Sans 12"

section "Setting xdg defaults..."
xdg-mime default thunar.desktop inode/directory

ln -sfT ~/.config/Code ~/.config/Code\ -\ OSS

section "Installing vscode extensions..."
install-code-extensions \
    Rubymaniac.vscode-direnv \
    PKief.material-icon-theme zhuangtongfa.material-theme \
    k--kato.intellij-idea-keybindings 2gua.rainbow-brackets \
    ms-vscode.cpptools ms-vscode.cmake-tools \
    rust-lang.rust-analyzer tamasfe.even-better-toml \
    mtxr.sqltools mtxr.sqltools-driver-pg \
    fwcd.kotlin \
    redhat.vscode-yaml \
    fallenwood.vimL \
    golang.go \
    mechatroner.rainbow-csv \
    yzhang.markdown-all-in-one \
    mads-hartmann.bash-ide-vscode \
    bmewburn.vscode-intelephense-client \
    naumovs.color-highlight \
    chrislajoie.vscode-modelines \
    usernamehw.errorlens \
    buenon.scratchpads anweber.vscode-httpyac \
    bradlc.vscode-tailwindcss \
    circledev.glsl-canvas \
    emilast.LogFileHighlighter \
    esbenp.prettier-vscode \
    GitHub.copilot \
    github.vscode-github-actions \
    Gruntfuggly.todo-tree \
    IronGeek.vscode-env \
    JScearcy.rust-doc-viewer \
    ms-azuretools.vscode-docker \
    ms-dotnettools.vscode-dotnet-runtime \
    ms-kubernetes-tools.kind-vscode \
    ms-kubernetes-tools.vscode-kubernetes-tools \
    ms-vscode.cpptools-extension-pack \
    ms-vscode.cpptools-themes \
    ms-vscode.makefile-tools \
    ms-vscode.remote-explorer \
    ms-vscode-remote.remote-containers \
    ms-vscode-remote.remote-ssh \
    ms-vscode-remote.remote-ssh-edit \
    ms-vscode.test-adapter-converter \
    ms-vsliveshare.vsliveshare \
    naco-siren.gradle-language \
    Orta.vscode-jest \
    paulheg.image-diff \
    raczzalan.webgl-glsl-editor \
    redhat.java \
    redhat.vscode-xml \
    richardwillis.vscode-gradle-extension-pack \
    sandipchitale.vscode-kubernetes-edit-kubeconfig \
    sandipchitale.vscode-kubernetes-helm-extension-pack \
    sandipchitale.vscode-kubernetes-helm-extras \
    shengchen.vscode-checkstyle \
    streetsidesoftware.code-spell-checker \
    tomoki1207.pdf \
    vscjava.vscode-gradle \
    vscjava.vscode-java-debug \
    vscjava.vscode-java-dependency \
    vscjava.vscode-java-pack \
    vscjava.vscode-java-test \
    vscjava.vscode-lombok \
    vscjava.vscode-maven \
    waderyan.gitblame \
    wgsl-analyzer.wgsl-analyzer \
    znck.grammarly \
    | prepend '  '

section "Adding userChrome to firefox..."
# Firefox
[ -d ~/.mozilla/firefox/ ] && find ~/.mozilla/firefox -maxdepth 1 -type d \( -name '*dev-edition-default*' -o -name '*default-release*' \) \
    -execdir mkdir -p {}/chrome \; \
    -execdir ln -sf "$ROOT/user/firefox/userChrome.css" {}/chrome/userChrome.css \;
