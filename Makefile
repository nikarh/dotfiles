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
		 install_packages
.PHONY: install

install_profile:
	${ln} -s ${PWD}/.profile ~/.profile

install_bash:
	@mkdir -p ~/.config
	${ln} -s ${PWD}/.config/bash ~/.config/bash
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
	${ln} -s ${PWD}/.config/git ~/.config/git

install_xprofile:
	@mkdir -p ~/.config
	${ln} -s ${PWD}/.config/Xorg ~/.config/Xorg
	${ln} -s ~/.config/Xorg/xprofile ~/.xprofile

install_packages:
	@yaourt -S nvim tmux bash-git-prompt rofi