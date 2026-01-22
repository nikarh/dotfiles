#!/usr/bin/env bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

section "Making everything makeable..."
find -L "$ROOT/user/tools" -name Makefile -execdir make "BIN=$ROOT/user/home/.local/bin" \; | prepend '  '

section "Linking configs..."
cp -frsTv "$ROOT/user/home/" ~ | prepend '  '

source "$ROOT/user/home/.profile"

systemctl enable --user syncthing
systemctl enable --user sunshine || true
systemctl enable --user ssh-agent
systemctl enable --user voxtype || true

section "Downloading random stuff from the internet..."
git-get https://github.com/mrzool/bash-sensible.git \
    ~/.config/bash-sensible | prepend '  '
git-get https://github.com/tmux-plugins/tpm.git \
    ~/.config/tmux/plugins/tpm | prepend '  '
file-get https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    ~/.config/nvim/autoload/plug.vim | prepend '  '

section "Updating vim plugins..."
nvim +PlugClean! +PlugUpdate +qa

section "Setting default gtk terminal to alacritty..."
gsettings set org.gnome.desktop.default-applications.terminal exec alacritty
gsettings set org.gnome.desktop.default-applications.terminal exec-arg -e
gsettings set org.gnome.desktop.interface font-name "Noto Sans 12"

section "Setting xdg defaults..."
xdg-mime default thunar.desktop inode/directory

# section "Installing vscode extensions..."
# install-code-extensions \
#     alexisvt.flutter-snippets \
#     anweber.vscode-httpyac \
#     bradlc.vscode-tailwindcss \
#     buenon.scratchpads \
#     chrislajoie.vscode-modelines \
#     dart-code.dart-code \
#     dart-code.flutter \
#     emilast.logfilehighlighter \
#     esbenp.prettier-vscode \
#     formulahendry.dotnet-test-explorer \
#     github.copilot \
#     github.copilot-chat \
#     irongeek.vscode-env \
#     jock.svg \
#     k--kato.intellij-idea-keybindings \
#     localizely.flutter-intl \
#     mads-hartmann.bash-ide-vscode \
#     mechatroner.rainbow-csv \
#     mikhail-arkhipov.armassemblyeditor \
#     ms-azuretools.vscode-docker \
#     ms-dotnettools.csdevkit \
#     ms-dotnettools.csharp \
#     ms-dotnettools.vscode-dotnet-runtime \
#     ms-kubernetes-tools.vscode-kubernetes-tools \
#     ms-python.black-formatter \
#     ms-python.debugpy \
#     ms-python.python \
#     ms-python.vscode-pylance \
#     ms-vscode-remote.remote-containers \
#     ms-vscode.cmake-tools \
#     ms-vscode.cpptools \
#     ms-vscode.cpptools-extension-pack \
#     ms-vscode.cpptools-themes \
#     ms-vscode.makefile-tools \
#     ms-vscode.test-adapter-converter \
#     mtxr.sqltools \
#     mtxr.sqltools-driver-pg \
#     naumovs.color-highlight \
#     orta.vscode-jest \
#     pkief.material-icon-theme \
#     qufiwefefwoyn.inline-sql-syntax \
#     qwtel.sqlite-viewer \
#     raczzalan.webgl-glsl-editor \
#     redhat.vscode-xml \
#     redhat.vscode-yaml \
#     rubymaniac.vscode-direnv \
#     rust-lang.rust-analyzer \
#     sandipchitale.vscode-kubernetes-helm-extension-pack \
#     streetsidesoftware.code-spell-checker \
#     tamasfe.even-better-toml \
#     tauri-apps.tauri-vscode \
#     usernamehw.errorlens \
#     vadimcn.vscode-lldbb \
#     waderyan.gitblame \
#     wcrichton.flowistry \
#     wgsl-analyzer.wgsl-analyzer \
#     yzhang.markdown-all-in-one \
#     zhuangtongfa.material-theme \
#     znck.grammarly \
#     | prepend '  '

section "Adding userChrome to firefox..."
# Firefox
[ -d ~/.mozilla/firefox/ ] && find ~/.mozilla/firefox -maxdepth 1 -type d \( -name '*dev-edition-default*' -o -name '*default-release*' \) \
    -execdir mkdir -p {}/chrome \; \
    -execdir ln -sf "$ROOT/user/firefox/userChrome.css" {}/chrome/userChrome.css \;
