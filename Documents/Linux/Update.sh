#!/bin/bash

BACKUP_DIR=".backup"
BACKUP_GIT_HTTPS_REPO="https://github.com/Shirobachi/super-duper-octo-spork.git"
GIT_PREFIX="git --git-dir=$HOME/$BACKUP_DIR --work-tree=$HOME"
# shellcheck disable=SC1091
. "$HOME"/Documents/Linux/.env 2>/dev/null

function clone_bare_repo(){
	git clone --bare "$BACKUP_GIT_HTTPS_REPO" "$HOME"/"$BACKUP_DIR"																						# Clone (bare) repo
	$GIT_PREFIX checkout --force																																							# Checkout files
	$GIT_PREFIX config --local status.showUntrackedFiles no																										# Hide untracked files
}

function restore_changes(){
	datetime=changes-$(date +%Y-%m-%d_%H-%M-%S)
	mkdir -p "$HOME"/Downloads/"$datetime"

	# Move changes to Downloads
	$GIT_PREFIX status --porcelain | while read -r line; do
		# Get file name and fire dir name
		file=$(echo "$line" | awk '{print $2}')
		fileDirectory=$(dirname "$file")

		# Create dir if not exist and move file
		mkdir -p "$HOME"/Downloads/"$datetime"/"$fileDirectory"
		mv "$HOME"/"$file" "$HOME"/Downloads/"$datetime"/"$file"

		# Restore file
		$GIT_PREFIX restore "$file"

		# Add log echo
		echo "$file" restore to default state
	done
}

function pull_changes(){
	$GIT_PREFIX pull --force
}

function push_changes(){
	date=$(date +%Y-%m-%d_%H-%M-%S)

	# Commit all changes
	$GIT_PREFIX commit -am "Backup update from $date"

	# Pull and push
	$GIT_PREFIX pull
	$GIT_PREFIX push
}

function install_and_run_ansible(){
	# install ansible 
	# shellcheck disable=SC1091
	. /etc/os-release
	if [[ "$ID" == "manjaro" ]]; then
		sudo pacman -Syu --noconfirm --needed ansible
	else
		echo "Unsupported OS"
		exit 1
	fi

	# Run ansible playbook in pull mode
	ansible-pull -U "$BACKUP_GIT_HTTPS_REPO" Documents/Linux/Update.yml --purge

}

# ======================== Main ========================

# Clone repo if not exist
if [[ ! -d $BACKUP_DIR ]]; then
	clone_bare_repo
# else deal with existing repo (push or pull)
else
	# Check if master of backup
	if [[ "$DOI_BACKUP_MASTER" == "true" ]]; then
		push_changes
	else
		# If there are changes?
		if [[ $($GIT_PREFIX status --porcelain | wc -l) -gt 0 ]]; then
			restore_changes
		fi

		# Pull changes
		pull_changes
	fi
fi

install_and_run_ansible

if [[ "$#" -eq 1 ]]; then
	/bin/bash
fi