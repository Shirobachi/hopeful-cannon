#!/bin/bash
# shellcheck disable=SC1091

# # # # # # # # # # # # # # # INTERNAL FUNCTIONS # # # # # # # # # # # # # # # 

# INFO: Clone repository "$1" to "$2" location, move conflits files to ~/Downloads/$datetime location
# $1 - directory of the repository
# $2 - repo (user/repo)
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
# $1 - directory of the repository
# $2 - repo (user/repo)
function pull_repo(){
	if [[ "$#" -ne 2 ]]; then
		exit 1
	fi
	DOI_BACKUP_DIR=$1
	DOI_BACKUP_REPO=$2
	BACKUP_GIT_HTTPS_REPO="https://github.com/$DOI_BACKUP_REPO.git"
	GIT_COMMAND_PREFIX="git --git-dir=$DOI_BACKUP_DIR --work-tree=$HOME"

	# check if git url is https
	if [[ $($GIT_COMMAND_PREFIX remote get-url origin) != https* ]]; then
		# convert to ssh
		echo "Converting git url to https"
		$GIT_COMMAND_PREFIX remote set-url origin "$BACKUP_GIT_HTTPS_REPO"
	fi

	# pulling thinkgs

	if [[ $(git --git-dir=/home/simon/.backup --work-tree=/home/simon status --porcelain | wc -l) -ne 0 ]]; then 
		datetime=$(date +%Y-%m-%d_%H-%M-%S)
		backup_dir="$HOME"/Downloads/backup_"$datetime"/

		mkdir -p "$backup_dir"
		$GIT_COMMAND_PREFIX status --porcelain | awk '{print $2}' | xargs -I{} mv "$HOME"/{} "$backup_dir"
		$GIT_COMMAND_PREFIX checkout --force
	fi 
}

# INFO: Push changes to remote repository, conflict from remote are ignored
# $1 - directory of the repository
# $2 - repo (user/repo)
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
	datetime=$(date +%Y-%m-%d\ %H:%M:%S)
	
	$GIT_COMMAND_PREFIX config pull.rebase false
	$GIT_COMMAND_PREFIX commit -am "Backup $datetime" || true
	$GIT_COMMAND_PREFIX pull
	$GIT_COMMAND_PREFIX push origin master --force
}

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
load_variables

# exit if required variables are not loaded
if [[ -z "$DOI_BACKUP_DIR" ]] || [[ -z "$DOI_BACKUP_REPO" ]] || [[ -z "$DOI_BACKUP_MODE" ]]; then
	exit 1
fi

# INFO: This script is for private use only, it's not intended to be used by others, but feel free to use it if you want
#       It's a simple script that backup my home directory to a remote git repository
#       ~~Also work with ansible-pull command for configuration purpose~~
# $1 - sleep time in seconds
# # # # # # # # # # # # # # # MAIN # # # # # # # # # # # # # # # 

	if [[ ! -d $DOI_BACKUP_DIR ]]; then
		clone_bare_repo "$DOI_BACKUP_DIR" "$DOI_BACKUP_REPO"
	else 
		if [[ "$(echo "$DOI_BACKUP_MODE" | tr '[:lower:]' '[:upper:]')" = "SLAVE" ]]; then
			echo "$DOI_BACKUP_MODE has been detected!"
			pull_repo "$DOI_BACKUP_DIR" "$DOI_BACKUP_REPO"
		elif [[ "$(echo "$DOI_BACKUP_MODE" | tr '[:lower:]' '[:upper:]')" = "MASTER" ]]; then
			echo "$DOI_BACKUP_MODE has been detected!"
			push_repo "$DOI_BACKUP_DIR" "$DOI_BACKUP_REPO"
		fi
	fi

save_variables

echo exitted with code $?