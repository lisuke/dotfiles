#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export PATH

# if [ -t 1 ]; then
# 	# exec zsh
# fi

export http_proxy=""
export https_proxy=""
export ftp_proxy=""
export socks_proxy=""

if [ -e $HOME/scripts/custom_shell_rc ]; then
	source $HOME/scripts/custom_shell_rc
fi

