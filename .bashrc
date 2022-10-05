#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC1090

# # # # # # # # # # Core # # # # # # # # # #

# load assets
if [[ ! -f "$HOME/Documents/Linux/assets.sh" ]]; then
	echo "Loading assets from remote "
	curl -s "https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/assets.sh" -o /tmp/assets.sh && source /tmp/assets.sh
else
	source "$HOME/Documents/Linux/assets.sh" # Load assets
fi
load_variables
prepend "$0"

shopt -s expand_aliases 2>/dev/null 
shopt -s autocd 2>/dev/null #allow use dir instead cd dir

# History size and time format
export HISTTIMEFORMAT="%d-%m-%y %T: "
HISTSIZE=9999
HISTFILESIZE=9999

# variables
export PS1="[\[\e[33m\]\u\[\e[m\]@\[\e[34m\]\h\[\e[m\]] \[\e[35m\]\w\[\e[m\] ⇨ "
export VISUAL=code;
export EDITOR=code;
export LANG=en_US.UTF-8

# # # # # # # # # # Aliases # # # # # # # # # #

alias ll='ls -lAh'
alias r='ranger'
alias manjaro='docker run -tiv /home/simon/Documents/Linux:/home/jenkins/BACKUP -v /home/simon/Documents/Linux/assets.sh:/home/jenkins/Documents/Linux/assets.sh hadogenes/manjaro-jenkins /bin/bash'
alias xclipp='xclip -selection clipboard'
alias backup='git --git-dir=$DOI_BACKUP_DIR --work-tree=$HOME'
alias update='$HOME/Documents/Linux/Update.sh'

# # # # # # # # # # Functions # # # # # # # # # #

function c() {
	# curl with all parameters
	curl -s "cheat.sh/$*"
}

function CODE(){
	# open vscode and terminate terminal
	code "$@" && exit
}

append "$0"