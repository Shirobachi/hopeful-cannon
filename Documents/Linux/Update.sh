#!/bin/bash
# shellcheck disable=SC1091

# # # # # # # # # # # # # # # CORE # # # # # # # # # # # # # # # 

set -e # Exit on error
# if any parameter is equal to "debug" or "-d" or "--debug" then set -x
for i in "$@"; do
  if [[ $i == "debug" ]] || [[ $i == "-d" ]] || [[ $i == "--debug" ]]; then
		set -x
  fi
done

# load assets
if [[ ! -f "$HOME/Documents/Linux/assets.sh" ]]; then
	echo "Loading assets from remote "
	curl -s "https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/assets.sh" -o /tmp/assets.sh && source /tmp/assets.sh
else
	source "$HOME/Documents/Linux/assets.sh" # Load assets
fi

# # # # # # # # # # # # # # # INTERNAL FUNCTIONS # # # # # # # # # # # # # # # 

# INFO: Clone repository "$1" to "$2" location, move conflits files to ~/Downloads/$datetime location
# $1 - repository to clone
# $2 - location to clone to
# $3 - prefix command for git commands
function clone_bare_repo(){
	if [[ "$#" -ne 2 ]]; then
		exit 1
	fi
	DOI_BACKUP_REPO=$1
	DOI_BACKUP_DIR=$2
	BACKUP_GIT_HTTPS_REPO="https://github.com/$DOI_BACKUP_REPO.git"
	GIT_COMMAND_PREFIX="git --git-dir=$DOI_BACKUP_DIR --work-tree=$HOME"

	echo "Cloning bare repo for the first time..."
	git clone --bare "$BACKUP_GIT_HTTPS_REPO" "$DOI_BACKUP_DIR"
	$GIT_COMMAND_PREFIX config --local status.showUntrackedFiles no

	if [[ ! $($GIT_COMMAND_PREFIX checkout) ]]; then
		datetime=$(date +%Y-%m-%d_%H-%M-%S)
		backup_dir="$HOME"/Downloads/backup_"$datetime"/

		mkdir -p "$backup_dir"
		$GIT_COMMAND_PREFIX checkout 2>&1 | grep -e "^\s" | awk '{print $1}' | xargs -I{} mv "$HOME"/{} "$backup_dir"
		$GIT_COMMAND_PREFIX checkout --force

		# remove $backup_dir if it's empty
		if [[ ! $(ls -A "$backup_dir") ]]; then
			rmdir "$backup_dir"
		else
			echo "Found uncommited changes in the backup repo. Moving them to $backup_dir"
		fi
	fi
}

# INFO: Pull changes from remote repository, move conflits files to ~/Downloads/$datetime location
# $1 - prefix command for git commands
# function pull_repo(){
# TODO: check if https and set https if not
# 	if [[ "$#" -ne 1 ]]; then
# 		exit 1
# 	fi
# 	DOI_BACKUP_DIR=$1
# 	GIT_COMMAND_PREFIX="git --git-dir=$DOI_BACKUP_DIR --work-tree=$HOME"

# 	$GIT_COMMAND_PREFIX pull
# }

function push_repo(){
	if [[ "$#" -ne 2 ]]; then
		exit 1
	fi
	DOI_BACKUP_DIR=$1
	DOI_BACKUP_REPO=$2
	BACKUP_GIT_SSH_REPO=git@github.com:"$DOI_BACKUP_REPO".git
	GIT_COMMAND_PREFIX="git --git-dir=$DOI_BACKUP_DIR --work-tree=$HOME"

	# check if git url is https
	if [[ $($GIT_COMMAND_PREFIX remote get-url origin) == https* ]]; then
		# convert to ssh
		echo "Converting git url to ssh"
		$GIT_COMMAND_PREFIX remote set-url origin "$BACKUP_GIT_SSH_REPO"
	fi

	# Finaly send changes to remote repo
	datetime=$(date +%Y-%m-%d_%H-%M-%S)
	
	$GIT_COMMAND_PREFIX config pull.rebase false
	$GIT_COMMAND_PREFIX commit -am "Backup $datetime"
	$GIT_COMMAND_PREFIX pull
	$GIT_COMMAND_PREFIX push origin master --force
	
}

# # # # # # # # # # # # # # # MAIN # # # # # # # # # # # # # # # 

load_variables
if [[ -z "$DOI_BACKUP_DIR" ]] || [[ -z "$DOI_BACKUP_REPO" ]] || [[ -z "$DOI_BACKUP_MODE" ]]; then
	exit 1
fi

if [[ ! -d $DOI_BACKUP_DIR ]]; then
	clone_bare_repo "$DOI_BACKUP_REPO" "$DOI_BACKUP_DIR"
else 
	if [[ "$(echo "$DOI_BACKUP_MODE" | tr '[:lower:]' '[:upper:]')" = "SLAVE" ]]; then
		echo "$DOI_BACKUP_MODE has been detected!"
		# pull_repo "$DOI_BACKUP_DIR"
	elif [[ "$(echo "$DOI_BACKUP_MODE" | tr '[:lower:]' '[:upper:]')" = "MASTER" ]]; then
		echo "$DOI_BACKUP_MODE has been detected!"
		
		push_repo "$DOI_BACKUP_DIR" "$DOI_BACKUP_REPO"
	fi
fi

save_variables