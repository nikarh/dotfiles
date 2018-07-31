.DEFAULT_GOAL: install

ln 	?= ln -f
PWD ?= $(shell pwd)

install: install_profile \
		 install_bash \
  		 install_bash_sensible \
		 install_nvim \
		 install_tmux \
		 install_git \
		 install_xprofile \
		 install_packages \
		 autostart
.PHONY: install

install_profile:
	${ln} -s ${PWD}/.profile ~/.profile

install_bash:
	@mkdir -p ~/.config
	${ln} -s ${PWD}/.config/bash ~/.config/
	${ln} -s ~/.config/bash/bashrc ~/.bashrc
	${ln} -s ~/.config/bash/bash_logout ~/.bash_logout
	${ln} -s ~/.config/bash/inputrc ~/.inputrc

install_bash_sensible:
	@mkdir -p ~/.config/bash-sensible
	@git clone git@github.com:mrzool/bash-sensible.git ~/.config/bash-sensible
	@sed -i 's/^shopt -s cdable_vars/#shopt -s cdable_vars/' \
		~/.config/bash-sensible/sensible.bash

install_nvim:
	@mkdir -p ~/.config/nvim
	${ln} -s ${PWD}/.config/nvim/init.vim ~/.config/nvim/init.vim
	curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

install_tmux:
	@mkdir -p ~/.config/tmux
	@git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
	${ln} -s ${PWD}/.tmux.conf ~/.tmux.conf

install_git:
	@mkdir -p ~/.config
	${ln} -s ${PWD}/.config/git ~/.config/

install_xprofile:
	@mkdir -p ~/.config
	${ln} -s ${PWD}/.config/Xorg ~/.config/
	cd ~/.config/Xorg/control && make deps build clean
	${ln} -s ~/.config/Xorg/xprofile ~/.xprofile

install_packages:
	@sudo pacman --noconfirm -S neovim tmux rofi bash-completion fzf exa fd httpie ripgrep jq
	@sudo pacman --noconfirm -S awesome cbatticon pavucontrol gpicview-gtk3 gsimplecal noto-fonts noto-fonts-emoji ttf-dejavu ttf-hack xarchiver xclip xdg-utils xorg-xev xorg-xinput xorg-xrandr xorg-xprop xorg-xrdb xorg-xset xorg-xmodmap xorg-xkbcomp
	@sudo pacman --noconfirm -S alsa-tools dnscrypt-proxy docker
	@sudo pacman --noconfirm -S firefox chromium thunderbird keepassxc blueman lxappearance-gtk3 lxsession-gtk3 qt5-styleplugins
	@sudo pacman --noconfirm -S arc-gtk-theme arc-solid-gtk-theme
	@yaourt -S bash-git-prompt insync systemd-boot-pacman-hook direnv 
	@yaourt -S adapta-grk-theme-git alacritty-git paper-gtk-theme-git super-flat-remix-icon-theme ttf-font-awesome-4

autostart:
	@mkdir -p ~/.config/autostart
	@ln -s /usr/share/applications/insync.desktop ~/.config/autostart/
	@ln -s /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.config/autostart/
	@ln -s /usr/share/applications/firefox.desktop ~/.config/autostart
	@ln -s /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.config/autostart/
	@ln -s /usr/share/applications/pasystray.desktop ~/.config/autostart
	@ln -s /usr/share/applications/libinput-gestures.desktop ~/.config/autostart
	

