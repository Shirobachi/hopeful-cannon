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
if [[ ! -f $(pwd)/assets.sh ]]; then
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

	echo "Cloning bare repo for the first time..."
	git clone --bare "$BACKUP_GIT_HTTPS_REPO" "$DOI_BACKUP_DIR"
	GIT_COMMAND_PREFIX="git --git-dir=$DOI_BACKUP_DIR --work-tree=$HOME"

	if [[ $($GIT_COMMAND_PREFIX status --porcelain | wc -l) -ne 0 ]]; then
		datetime=$(date +%Y-%m-%d_%H-%M-%S)
		backup_dir="$HOME"/Downloads/backup_"$datetime"

		mkdir "$backup_dir"
		$GIT_COMMAND_PREFIX checkout 2>&1 | grep -e "\s+\." | awk \{'print $1'\} | xargs -I{} mv {} "$HOME/Downloads/backup_$datetime"/{}
		$GIT_COMMAND_PREFIX reset --hard
	fi

	$GIT_COMMAND_PREFIX config --local status.showUntrackedFiles no
	$GIT_COMMAND_PREFIX checkout --force
}

# # # # # # # # # # # # # # # MAIN # # # # # # # # # # # # # # # 

load_variables
DOI_BACKUP_DIR=${DOI_BACKUP_DIR:-"$HOME/.backup"}
DOI_BACKUP_REPO=${DOI_BACKUP_REPO:-"Shirobachi/super-duper-octo-spork"}
BARE_REPO_ADDRESS="https://github.com/$DOI_BACKUP_REPO.git"

if [[ ! -d $DOI_BACKUP_DIR/.git ]]; then
	clone_bare_repo "$BARE_REPO_ADDRESS" "$DOI_BACKUP_DIR"
fi

save_variables