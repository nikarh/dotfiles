.DEFAULT_GOAL: install

ln			?= ln -f
PWD			?= $(shell pwd)
pacman		?= yay --noconfirm
aur			?= yay --noconfirm
systemctl	?= sudo systemctl
gpasswd		?= sudo gpasswd
user		?= $(shell id -un)
hostname	?= $(shell cat /etc/hostname)

install: generate_ssh_key \
	 install_alacritty \
	 install_profile \
	 install_bash \
  	 install_bash_sensible \
	 install_nvim \
	 install_tmux \
	 install_git \
	 install_xprofile \
	 install_autostart \
	 install_awesome \
	 install_firefox \
	 install_gtk
.PHONY: install

generate_ssh_key:
	@if [ ! -f $$HOME/.ssh/id_rsa ]; then \
		ssh-keygen -C $(hostname) -f $$HOME/.ssh/id_rsa -P ""; \
	fi

create_config:
	@mkdir -p ~/.config
	@mkdir -p ~/.config/autostart

install_profile:
	$(ln) -s $(PWD)/.profile ~/.profile

install_alacritty:
	rm -rf ~/.config/alacritty
	$(ln) -s $(PWD)/.config/alacritty ~/.config/alacritty

delete_awesome:
	rm -rf ~/.config/awesome/tyrannical

install_awesome: delete_awesome
	$(ln) -s $(PWD)/.config/awesome ~/.config/awesome
	cd ~/.config/awesome && git clone https://github.com/Elv13/tyrannical.git

install_bash: create_config
	$(ln) -s $(PWD)/.config/bash ~/.config/
	$(ln) -s ~/.config/bash/bashrc ~/.bashrc
	$(ln) -s ~/.config/bash/bash_logout ~/.bash_logout
	$(ln) -s ~/.config/bash/inputrc ~/.inputrc

delete_bash_sensible:
	rm -rf ~/.config/bash-sensible

install_bash_sensible: delete_bash_sensible create_config
	@mkdir -p ~/.config/bash-sensible
	@git clone https://github.com/mrzool/bash-sensible.git ~/.config/bash-sensible
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
	cd ~/.config/Xorg/control && make build
	$(ln) -s ~/.config/Xorg/xprofile ~/.xprofile

install_apps:
	$(ln) -s $(PWD)/.local/share/

install_autostart:
	@mkdir -p ~/.config/autostart
	$(ln) -s /usr/share/applications/insync.desktop ~/.config/autostart/
	$(ln) -s /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.config/autostart/
	$(ln) -s /usr/share/applications/firefox.desktop ~/.config/autostart
	$(ln) -s /usr/share/applications/pasystray.desktop ~/.config/autostart
	$(ln) -s /usr/share/applications/libinput-gestures.desktop ~/.config/autostart
	@mkdir -p ~/.local/share/applications
	$(ln) -s $(PWD)/.local/share/applications/bilderlings.slack.com.desktop ~/.local/share/applications
	$(ln) -s $(PWD)/.local/share/applications/messenger.desktop ~/.local/share/applications
	$(ln) -s $(PWD)/.local/share/applications/spotify.desktop ~/.local/share/applications

install_firefox:
	cd ~/.mozilla/firefox/ && \
	cd $$(ls | grep .\\.default) && \
	mkdir -p chrome && \
	cp $(PWD)/userChrome.css chrome/userChrome.css

install_gtk:
	@mkdir -p ~/.config/gtk-3.0
	rm -f ~/.config/gtk-3.0/settings.ini
	$(ln) -s $(PWD)/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0