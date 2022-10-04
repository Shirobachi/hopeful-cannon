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
	curl -s "https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/assets.sh" -o /tmp/assets.sh && source /tmp/assets.sh
else
	source ./assets.sh # Load assets
fi

# # # # # # # # # # # # # # # INTERNAL FUNCTIONS # # # # # # # # # # # # # # # 

function clone_bare_repo(){
	if [[ "$#" -ne 2 ]]; then
		exit 1
	fi
	BACKUP_GIT_HTTPS_REPO=$1
	DOI_BACKUP_DIR=$2
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

# # # # # # # # # # # # # # # MAIN # # # # # # # # # # # # # # # 

load_variables
DOI_BACKUP_DIR=${DOI_BACKUP_DIR:-"$HOME/.backup"}
DOI_BACKUP_REPO=${DOI_BACKUP_REPO:-"Shirobachi/super-duper-octo-spork"}
BACKUP_GIT_HTTPS_REPO="https://github.com/$DOI_BACKUP_REPO.git"

if [[ ! -d $DOI_BACKUP_DIR ]]; then
	clone_bare_repo "$BACKUP_GIT_HTTPS_REPO" "$DOI_BACKUP_DIR"
fi

save_variables