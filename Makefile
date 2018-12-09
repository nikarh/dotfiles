.DEFAULT_GOAL: install

ln			?= ln -f
PWD			?= $(shell pwd)
pacman		?= sudo pacman --noconfirm
aur			?= yaourt --noconfirm
systemctl	?= sudo systemctl
user		?= id -un

install: install_profile \
		 install_bash \
  		 install_bash_sensible \
		 install_nvim \
		 install_tmux \
		 install_git \
		 install_xprofile \
		 install_packages \
		 install_autostart \
		 install_localtime \
		 install_awesome \
		 add_groups
.PHONY: install

create_config:
	@mkdir -p ~/.config
	@mkdir -p ~/.config/autostart

install_profile:
	$(ln) -s $(PWD)/.profile ~/.profile

delete_awesome:
	rm -rf ~/.config/awesome/tyrannical

install_awesome: delete_awesome
	$(ln) -s $(PWD)/.config/awesome ~/.config/awesome
	cd ~/.config/awesome && git clone git@github.com:Elv13/tyrannical.git

install_bash: create_config
	$(ln) -s $(PWD)/.config/bash ~/.config/
	$(ln) -s ~/.config/bash/bashrc ~/.bashrc
	$(ln) -s ~/.config/bash/bash_logout ~/.bash_logout
	$(ln) -s ~/.config/bash/inputrc ~/.inputrc

delete_bash_sensible:
	rm -rf ~/.config/bash-sensible

install_bash_sensible: delete_bash_sensible create_config
	@mkdir -p ~/.config/bash-sensible
	@git clone git@github.com:mrzool/bash-sensible.git ~/.config/bash-sensible
	@sed -i 's/^shopt -s cdable_vars/#shopt -s cdable_vars/' \
		~/.config/bash-sensible/sensible.bash

install_nvim: create_config
	@mkdir -p ~/.config/nvim
	$(ln) -s $(PWD)/.config/nvim/init.vim ~/.config/nvim/init.vim
	curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

delete_tmux:
	rm -rf ~/.config/tmux/plugins/tpm

install_tmux: delete_tmux create_config
	@mkdir -p ~/.config/tmux
	@git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
	$(ln) -s $(PWD)/.tmux.conf ~/.tmux.conf

install_git: create_config
	$(ln) -s $(PWD)/.config/git ~/.config/

install_xprofile: create_config
	$(ln) -s $(PWD)/.config/Xorg ~/.config/
	cd ~/.config/Xorg/control && make deps build clean
	$(ln) -s ~/.config/Xorg/xprofile ~/.xprofile

install_packages:
	# Console utils
	$(pacman) -S tmux neovim bash-completion fzf exa fd httpie ripgrep jq \
		alsa-tools dnscrypt-proxy docker diff-so-fancy
	# Xorg apps and utils
	$(pacman) -S awesome rofi cbatticon pavucontrol \
		firefox chromium thunderbird keepassxc blueman \
		lxappearance-gtk3 lxsession-gtk3 qt5-styleplugins \
		gpicview-gtk3 xarchiver gsimplecal \
		xclip xdg-utils xorg-xev xorg-xinput xorg-xrandr autorandr \
		xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap xorg-xkbcomp xbindkeys \
		gnome-screenshot alacritty
	# Themes
	$(pacman) -S noto-fonts noto-fonts-emoji ttf-dejavu ttf-hack \
	 	arc-gtk-theme arc-solid-gtk-theme adapta-gtk-theme
	# AUR non-GUI
	$(aur) -S bash-git-prompt systemd-boot-pacman-hook direnv \
		intel-hybrid-codec-driver libva-intel-driver-hybrid \
		terminess-powerline-font-git light
	# AUR GUI tools
	$(aur) -S insync freshplayerplugin libinput-gestures
	# AUR Themes
	$(aur) -S flat-remix-git ttf-font-awesome-4
	$(pacman) -S thunar gvfs-smb
	$(aur) -S pulseaudio-modules-bt-git
	# Enable services
	$(systemctl) enable --now docker.service

install_autostart:
	@mkdir -p ~/.config/autostart
	$(ln) @ln -s /usr/share/applications/insync.desktop ~/.config/autostart/
	$(ln) @ln -s /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.config/autostart/
	$(ln) @ln -s /usr/share/applications/firefox.desktop ~/.config/autostart
	$(ln) @ln -s /usr/share/applications/pasystray.desktop ~/.config/autostart
	$(ln) @ln -s /usr/share/applications/libinput-gestures.desktop ~/.config/autostart

install_localtime:
	$(aur) -S localtime-git
	$(systemctl) enable --now localtime.service

add_groups:
	gpasswd --add $(user) docker
	gpasswd --add $(user) audio
	gpasswd --add $(user) video
	gpasswd --add $(user) storage
	gpasswd --add $(user) input
	gpasswd --add $(user) sudo
	gpasswd --add $(user) lp
	gpasswd --add $(user) systemd-journal
