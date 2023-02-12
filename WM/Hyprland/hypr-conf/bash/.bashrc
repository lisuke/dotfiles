#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
GOPATH=~/go
NODEPATH=~/.node_global
PATH=$PATH:$GOPATH/bin:$NODEPATH/bin
export PATH

if [ -t 1 ]; then
	exec zsh
fi
