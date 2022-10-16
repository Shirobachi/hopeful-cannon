#!/bin/bash
# shellcheck disable=SC1091
# shellcheck disable=SC1090
# shellcheck disable=SC2139

# # # # # # # # # # Core # # # # # # # # # #

# load assets
if [[ ! -f "$HOME/Documents/Linux/Backup/assets.sh" ]]; then
	echo "Loading assets from remote"
	curl -s "https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/Backup/assets.sh" -o /tmp/assets.sh && source /tmp/assets.sh
else
	source "$HOME/Documents/Linux/Backup/assets.sh" # Load assets
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
export VISUAL=micro;
export EDITOR=micro;
export LANG=en_US.UTF-8
export PATH="$PATH:$HOME/Documents/Linux/Backup/Apps/"

# # # # # # # # # # Aliases # # # # # # # # # #

alias ll='ls -lAh'
alias r='ranger'
alias manjaro='docker run -tiv /home/simon/Downloads:/home/jenkins/Documents/Linux/Backup/assets.sh hadogenes/manjaro-jenkins /bin/bash'
alias ubuntu='docker run -tiv /home/simon/Downloads:/home/jenkins/Documents/Linux/Backup/assets.sh ubuntu /bin/bash'
alias xclipp='xclip -selection clipboard'
alias backup='git --git-dir=$DOI_BACKUP_DIR --work-tree=$HOME'
alias update="$HOME/Documents/Linux/Backup/Update.sh"
alias update-backup="$HOME/Documents/Linux/Backup/Update-backup.sh"
alias update-ansible="$HOME/Documents/Linux/Backup/Update-ansible.sh"
alias code="code --add"
alias t="task $* && task"
alias ts="t start && t"
alias td="t done && t"
alias ta="t add && t"

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