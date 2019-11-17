.DEFAULT_GOAL: all

PWD			?= $(shell pwd)
hostname	?= $(shell cat /etc/hostname)

all: \
	ssh_key git bash tmux nvim \
	wm xprofile autostart \
	gtk application_defaults \
	vscode
.PHONY: all

init:
	@mkdir -p ~/.config \
			  ~/.config/autostart \
			  ~/.local/share/applications
.PHONY: init

ssh_key:
	@if [ ! -f $$HOME/.ssh/id_rsa ]; then \
		ssh-keygen -C $(hostname) -f $$HOME/.ssh/id_rsa -P ""; \
	fi
.PHONY: ssh_key

git: init
	# Linking .config/git
	@ln -sfT $(PWD)/home/.config/git ~/.config/git
.PHONY: git

bash: init
	# Linking .config/bash
	@ln -sfT $(PWD)/home/.config/bash ~/.config/bash
	@ln -sfT $(PWD)/home/.profile ~/.profile
	@ln -sfT ~/.config/bash/bashrc ~/.bashrc
	@ln -sfT ~/.config/bash/bash_logout ~/.bash_logout
	@ln -sfT ~/.config/bash/inputrc ~/.inputrc
	# Pulling bash-sensible
	@if [ ! -d ~/.config/bash-sensible ]; then \
		git -q clone https://github.com/mrzool/bash-sensible.git ~/.config/bash-sensible; \
		sed -i 's/^shopt -s cdable_vars/#shopt -s cdable_vars/' \
			~/.config/bash-sensible/sensible.bash; \
	else \
		cd ~/.config/bash-sensible && git pull -q; \
	fi
PHONY: bash

nvim: init
	# Linking .config/nvim/init.vim
	@mkdir -p ~/.config/nvim
	@ln -sfT $(PWD)/home/.config/nvim/init.vim ~/.config/nvim/init.vim
	# Installing Plug vim package manager
	@curl -s -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
.PHONY: nvim

tmux: init
	# Linking tmux.conf
	@mkdir -p ~/.config/tmux
	@ln -sfT $(PWD)/home/.tmux.conf ~/.tmux.conf
	# Pulling latest version of tmux package manager
	@if [ ! -d ~/.config/tmux/plugins/tpm ]; then \
		git -q clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm; \
	else \
		cd ~/.config/tmux/plugins/tpm && git pull -q; \
	fi
.PHONY: tmux

xprofile: init
	# Linking local Xorg configs
	@ln -sfT $(PWD)/home/.config/Xorg ~/.config/Xorg
	@ln -sfT ~/.config/Xorg/xprofile ~/.xprofile
	# Build udev monitor
	@cd ~/.config/Xorg/udev-monitor && make
.PHONY: xprofile

wm: init
	# Linking wm and de related configs
	@ln -sfT $(PWD)/home/.config/i3 ~/.config/i3
	@ln -sfT $(PWD)/home/.config/i3blocks ~/.config/i3blocks
	@ln -sfT $(PWD)/home/.config/dunst ~/.config/dunst
	@ln -sfT $(PWD)/home/.config/alacritty ~/.config/alacritty
.PHONY: wm

gtk: init
	@mkdir -p ~/.config/gtk-3.0
	# Linking gtk3 config file
	@ln -sfT $(PWD)/home/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
.PHONY: gtk

application_defaults:
	# Setting default gtk terminal to alacritty
	@gsettings set org.gnome.desktop.default-applications.terminal exec alacritty
	@gsettings set org.gnome.desktop.default-applications.terminal exec-arg -e
	# Setting xdg defaults
	@xdg-mime default Thunar.desktop inode/directory
.PHONY: application_defaults

autostart: init
	@ln -sf $(PWD)/home/.local/share/applications/*.desktop ~/.local/share/applications/
	# Adding applications to autostart
	@ln -sf /usr/share/applications/insync.desktop ~/.config/autostart/
	@ln -sf /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.config/autostart/
	@ln -sf /usr/share/applications/pasystray.desktop ~/.config/autostart/
	@ln -sf /usr/share/applications/libinput-gestures.desktop ~/.config/autostart/
	@ln -sf /usr/share/applications/nm-applet.desktop ~/.config/autostart/
	@ln -sf  ~/.local/share/applications/cbatticon.desktop ~/.config/autostart/
	@ln -sf  ~/.local/share/applications/redshift-gtk.desktop ~/.config/autostart/

	@cp /etc/xdg/autostart/{gnome-keyring-secrets.desktop,gnome-keyring-ssh.desktop} ~/.config/autostart/
	@sed -i '/^OnlyShowIn.*$$/d' ~/.config/autostart/gnome-keyring-secrets.desktop
	@sed -i '/^OnlyShowIn.*$$/d' ~/.config/autostart/gnome-keyring-ssh.desktop
.PHONY: autostart

vscode: init
	# Linking vscode configs
	@mkdir -p ~/.vscode
	@mkdir -p ~/.config/Code/User
	@ln -sfT ~/.vscode ~/.vscode-oss
	@ln -sfT ~/.config/Code ~/.config/Code\ -\ OSS
	@ln -sf $(PWD)/home/.config/vscode/* ~/.config/Code/User/
	# Installing vscode extensions
	@EXTENSIONS="\
		Rubymaniac.vscode-direnv \
		k--kato.intellij-idea-keybindings \
		PKief.material-icon-theme \
		fallenwood.vimL \
		keyring.Lua \
		ms-vscode.Go \
		ms-vscode.cpptools \
		redhat.vscode-yaml \
		mechatroner.rainbow-csv \
		yzhang.markdown-all-in-one \
		mads-hartmann.bash-ide-vscode \
		bmewburn.vscode-intelephense-client \
		naumovs.color-highlight \
		chrislajoie.vscode-modelines \
	"; \
	INSTALLED_EXTENSIONS=$$(code --list-extensions); \
	for EXTENSION in $$EXTENSIONS; do \
		if ! echo $$INSTALLED_EXTENSIONS | grep -qw $$EXTENSION; then \
			code --install-extension $$EXTENSION; \
		fi \
	done
.PHONY: vscode

firefox:
	# Install userChrome.css in firefox for tree style tab
	@cd $$(find ~/.mozilla/firefox/ -name '*.dev-edition-default') && mkdir -p chrome && \
		$(ln) -s $(PWD)/home/.config/firefox/userChrome.css ./chrome/userChrome.css
.PHONY: firefox
