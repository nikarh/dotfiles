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
	 install_bash \
	 install_nvim \
	 install_tmux \
	 install_git \
	 install_xprofile \
	 install_autostart \
	 install_awesome \
	 install_gtk \
	 install_vscode
.PHONY: install

generate_ssh_key:
	@if [ ! -f $$HOME/.ssh/id_rsa ]; then \
		ssh-keygen -C $(hostname) -f $$HOME/.ssh/id_rsa -P ""; \
	fi

init:
	@mkdir -p ~/.config
	@mkdir -p ~/.config/autostart
	@mkdir -p ~/.local/share/applications

install_alacritty:
	rm -rf ~/.config/alacritty
	$(ln) -s $(PWD)/.config/alacritty ~/.config/alacritty

install_awesome:
	$(ln) -s $(PWD)/.config/awesome ~/.config/awesome
	@if [ ! -d ~/.config/awesome/tyrannical ]; then \
		git clone https://github.com/Elv13/tyrannical.git ~/.config/awesome/tyrannical; \
	fi

install_bash: init
	$(ln) -s $(PWD)/.config/bash ~/.config/
	$(ln) -s $(PWD)/.profile ~/.profile
	$(ln) -s ~/.config/bash/bashrc ~/.bashrc
	$(ln) -s ~/.config/bash/bash_logout ~/.bash_logout
	$(ln) -s ~/.config/bash/inputrc ~/.inputrc
	@if [ ! -d ~/.config/bash-sensible ]; then \
		git clone https://github.com/mrzool/bash-sensible.git ~/.config/bash-sensible; \
		sed -i 's/^shopt -s cdable_vars/#shopt -s cdable_vars/' \
			~/.config/bash-sensible/sensible.bash; \
	fi

install_nvim: init
	@mkdir -p ~/.config/nvim
	$(ln) -s $(PWD)/.config/nvim/init.vim ~/.config/nvim/init.vim
	curl -s -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

install_tmux: init
	@mkdir -p ~/.config/tmux
	@if [ ! -d ~/.config/tmux/plugins/tpm ]; then \
		git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm; \
	fi
	$(ln) -s $(PWD)/.tmux.conf ~/.tmux.conf

install_git: init
	$(ln) -s $(PWD)/.config/git ~/.config/

install_xprofile: init
	$(ln) -s $(PWD)/.config/Xorg ~/.config/
	cd ~/.config/Xorg/control && go build -ldflags "-s -w" xcontrol
	$(ln) -s ~/.config/Xorg/xprofile ~/.xprofile

install_autostart: init	
	$(ln) -s $(PWD)/.local/share/applications/bilderlings.slack.com.desktop ~/.local/share/applications/
	$(ln) -s $(PWD)/.local/share/applications/messenger.desktop ~/.local/share/applications/
	$(ln) -s $(PWD)/.local/share/applications/spotify.desktop ~/.local/share/applications/
	$(ln) -s $(PWD)/.local/share/applications/firefox.desktop ~/.local/share/applications/
	$(ln) -s $(PWD)/.local/share/applications/cbatticon.desktop ~/.local/share/applications/
	$(ln) -s /usr/share/applications/insync.desktop ~/.config/autostart/
	$(ln) -s /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.config/autostart/
	$(ln) -s /usr/share/applications/pasystray.desktop ~/.config/autostart/
	$(ln) -s /usr/share/applications/libinput-gestures.desktop ~/.config/autostart/
	$(ln) -s ~/.local/share/applications/firefox.desktop ~/.config/autostart/
	$(ln) -s ~/.local/share/applications/cbatticon.desktop ~/.config/autostart/

install_vscode:
	@mkdir -p ~/.config/Code\ -\ OSS/User
	$(ln) -s $(PWD)/.config/vscode/settings.json ~/.config/Code\ -\ OSS/User/
	code --install-extension k--kato.intellij-idea-keybindings

install_firefox:
	cd $$(find ~/.mozilla/firefox/ -name '*.default') && mkdir -p chrome && \
	$(ln) -s $(PWD)/.config/firefox/userChrome.css ./chrome/userChrome.css

install_gtk:
	@mkdir -p ~/.config/gtk-3.0
	rm -f ~/.config/gtk-3.0/settings.ini
	$(ln) -s $(PWD)/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0