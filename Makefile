.DEFAULT_GOAL: all

PWD			?= $(shell pwd)
ln			?= ln -f
mkdir		?= mkdir -p
rm			?= rm -rf
user		?= $(shell id -un)
hostname	?= $(shell cat /etc/hostname)

all: \
	ssh_key \
	git \
	bash \
	tmux \
	nvim \
	alacritty \
	xprofile \
	awesomewm \
	dunst \
	autostart \
	gtk \
	application_defaults \
	vscode \

.PHONY: all

init:
	@$(mkdir) ~/.config
	@$(mkdir) ~/.config/autostart
	@$(mkdir) ~/.local/share/applications
.PHONY: init

ssh_key:
	@if [ ! -f $$HOME/.ssh/id_rsa ]; then \
		ssh-keygen -C $(hostname) -f $$HOME/.ssh/id_rsa -P ""; \
	fi
.PHONY: ssh_key

git: init
	# Link git config files
	@$(ln) -s $(PWD)/.config/git ~/.config/
.PHONY: git

alacritty: init
	# Link alacritty config files
	@$(rm) ~/.config/alacritty
	@$(ln) -s $(PWD)/.config/alacritty ~/.config/alacritty
.PHONY: alacritty

bash: init
	# Link bash config files
	@$(ln) -s $(PWD)/.config/bash ~/.config/
	@$(ln) -s $(PWD)/.profile ~/.profile
	@$(ln) -s ~/.config/bash/bashrc ~/.bashrc
	@$(ln) -s ~/.config/bash/bash_logout ~/.bash_logout
	@$(ln) -s ~/.config/bash/inputrc ~/.inputrc
	# Pull bash-sensible
	@if [ ! -d ~/.config/bash-sensible ]; then \
		git -q clone https://github.com/mrzool/bash-sensible.git ~/.config/bash-sensible; \
		sed -i 's/^shopt -s cdable_vars/#shopt -s cdable_vars/' \
			~/.config/bash-sensible/sensible.bash; \
	else \
		cd ~/.config/bash-sensible && git pull -q; \
	fi
PHONY: bash

nvim: init
	# Link nvim config file
	@$(mkdir) ~/.config/nvim
	@$(ln) -s $(PWD)/.config/nvim/init.vim ~/.config/nvim/init.vim
	# Install Plug package manager
	@curl -s -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
.PHONY: nvim

tmux: init
	# Link tmux config file
	@$(mkdir) ~/.config/tmux
	@$(ln) -s $(PWD)/.tmux.conf ~/.tmux.conf
	# Pull latest version of tmux package manager
	@if [ ! -d ~/.config/tmux/plugins/tpm ]; then \
		git -q clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm; \
	else \
		cd ~/.config/tmux/plugins/tpm && git pull -q; \
	fi
.PHONY: tmux

xprofile: init
	# Link Xorg config files
	@$(ln) -s $(PWD)/.config/Xorg ~/.config/
	@$(ln) -s ~/.config/Xorg/xprofile ~/.xprofile
	# Build custom xorg tools
	#@cd ~/.config/Xorg/control && go build -ldflags "-s -w" xcontrol
	@cd ~/.config/Xorg/udev-monitor && make
.PHONY: xprofile

awesomewm: init
	# Link awesomewm config
	@$(ln) -s $(PWD)/.config/awesome ~/.config/awesome
	# Pull latest version of tyrannical
	@if [ ! -d ~/.config/awesome/tyrannical ]; then \
		git -q clone https://github.com/Elv13/tyrannical.git ~/.config/awesome/tyrannical; \
	else \
		cd ~/.config/awesome/tyrannical && git pull -q; \
	fi
.PHONY: awesomewm

dunst: init
	@$(ln) -s $(PWD)/.config/dunst ~/.config/
.PHONY: dunst

gtk: init
	@$(mkdir) ~/.config/gtk-3.0
	# Link gtk3 config file
	@$(rm) ~/.config/gtk-3.0/settings.ini
	@$(ln) -s $(PWD)/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0
.PHONY: gtk

application_defaults:
	# Set default gtk terminal
	@gsettings set org.gnome.desktop.default-applications.terminal exec alacritty
	@gsettings set org.gnome.desktop.default-applications.terminal exec-arg -e
	# Set xdg defaults
	@xdg-mime default Thunar.desktop inode/directory
.PHONY: application_defaults

autostart: init
	@$(ln) -s $(PWD)/.local/share/applications/*.desktop ~/.local/share/applications/
	# Add applications to autostart
	@$(ln) -s /usr/share/applications/insync.desktop ~/.config/autostart/
	@$(ln) -s /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.config/autostart/
	@$(ln) -s /usr/share/applications/pasystray.desktop ~/.config/autostart/
	@$(ln) -s /usr/share/applications/libinput-gestures.desktop ~/.config/autostart/
	@$(ln) -s /usr/share/applications/nm-applet.desktop ~/.config/autostart/
	@$(ln) -s ~/.local/share/applications/vivaldi-stable.desktop ~/.config/autostart/
	@$(ln) -s ~/.local/share/applications/cbatticon.desktop ~/.config/autostart/
	@$(ln) -s ~/.local/share/applications/redshift-gtk.desktop ~/.config/autostart/
	# Autostarts gnome-keyring
	@cp /etc/xdg/autostart/{gnome-keyring-secrets.desktop,gnome-keyring-ssh.desktop} ~/.config/autostart/
	@sed -i '/^OnlyShowIn.*$$/d' ~/.config/autostart/gnome-keyring-secrets.desktop
	@sed -i '/^OnlyShowIn.*$$/d' ~/.config/autostart/gnome-keyring-ssh.desktop
.PHONY: autostart

vscode: init
	@$(mkdir) ~/.vscode-oss
	@$(ln) -s ~/.vscode-oss ~/.vscode
	@$(mkdir) ~/.config/Code\ -\ OSS/User
	@$(ln) -s $(PWD)/.config/vscode/* ~/.config/Code\ -\ OSS/User/
	@$(ln) -s ~/.config/Code\ -\ OSS ~/.config/Code
	# Install vscode Extensions
	@code --install-extension Rubymaniac.vscode-direnv
	@code --install-extension k--kato.intellij-idea-keybindings
	@code --install-extension pkief.material-icon-theme
	@code --install-extension kuscamara.electron
	@code --install-extension fallenwood.viml
	@code --install-extension keyring.lua
	@code --install-extension ms-vscode.go
	@code --install-extension ms-vscode.cpptools
	@code --install-extension redhat.vscode-yaml
	@code --install-extension mechatroner.rainbow-csv
	@code --install-extension yzhang.markdown-all-in-one
	@code --install-extension mads-hartmann.bash-ide-vscode
	@code --install-extension bmewburn.vscode-intelephense-client
	@code --install-extension naumovs.color-highlight
	@code --install-extension chrislajoie.vscode-modelines
.PHONY: vscode

firefox:
	# Install userChrome.css in firefox for tree style tab
	@cd $$(find ~/.mozilla/firefox/ -name '*.dev-edition-default') && $(mkdir) chrome && \
	$(ln) -s $(PWD)/.config/firefox/userChrome.css ./chrome/userChrome.css
.PHONY: firefox
