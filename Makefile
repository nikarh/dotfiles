.DEFAULT_GOAL: install

PWD			?= $(shell pwd)
ln			?= ln -f
mkdir		?= mkdir -p
rm 			?= rm -rf
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

init:
	@$(mkdir) ~/.config
	@$(mkdir) ~/.config/autostart
	@$(mkdir) ~/.local/share/applications

generate_ssh_key:
	@if [ ! -f $$HOME/.ssh/id_rsa ]; then \
		ssh-keygen -C $(hostname) -f $$HOME/.ssh/id_rsa -P ""; \
	fi

install_alacritty:
	$(rm) ~/.config/alacritty
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
	@$(mkdir) ~/.config/nvim
	$(ln) -s $(PWD)/.config/nvim/init.vim ~/.config/nvim/init.vim
	curl -s -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

install_tmux: init
	@$(mkdir) ~/.config/tmux
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
	$(ln) -s $(PWD)/.local/share/applications/* ~/.local/share/applications/
	$(ln) -s /usr/share/applications/insync.desktop ~/.config/autostart/
	$(ln) -s /usr/share/applications/org.keepassxc.KeePassXC.desktop ~/.config/autostart/
	$(ln) -s /usr/share/applications/pasystray.desktop ~/.config/autostart/
	$(ln) -s /usr/share/applications/libinput-gestures.desktop ~/.config/autostart/
	$(ln) -s ~/.local/share/applications/firefox.desktop ~/.config/autostart/
	$(ln) -s ~/.local/share/applications/cbatticon.desktop ~/.config/autostart/

install_vscode:
	@$(mkdir) ~/.config/Code\ -\ OSS/User
	$(ln) -s $(PWD)/.config/vscode/* ~/.config/Code\ -\ OSS/User/
	code --install-extension k--kato.intellij-idea-keybindings
	code --install-extension pkief.material-icon-theme

install_firefox:
	@cd $$(find ~/.mozilla/firefox/ -name '*.default') && $(mkdir) chrome && \
	$(ln) -s $(PWD)/.config/firefox/userChrome.css ./chrome/userChrome.css

install_gtk:
	@$(mkdir) ~/.config/gtk-3.0
	@$(rm) ~/.config/gtk-3.0/settings.ini
	$(ln) -s $(PWD)/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0