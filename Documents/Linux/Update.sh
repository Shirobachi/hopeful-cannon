#!/bin/bash
set -e # Exit on error
set -x 

# Load environment variables from .env file
if [[ -f "$HOME"/.env ]]; then
	# shellcheck disable=SC1091
	. "$HOME"/.env
fi

# Set environment variables if not set
if [[ -z "$DOI_BACKUP_REPO" ]]; then
	DOI_BACKUP_REPO="Shirobachi/super-duper-octo-spork"
fi
if [[ -z "$DOI_BACKUP_DIR" ]]; then
	DOI_BACKUP_DIR=".backup"
fi
if [[ -z "$DOI_BACKUP_MASTER" ]]; then
	DOI_BACKUP_MASTER="false"
fi

BACKUP_GIT_HTTPS_REPO="https://github.com/$DOI_BACKUP_REPO.git"
GIT_COMMAND_PREFIX="git --git-dir=$HOME/$DOI_BACKUP_DIR --work-tree=$HOME"

# ======================== Functions ========================

function clone_bare_repo(){
	git clone --bare "$BACKUP_GIT_HTTPS_REPO" "$HOME"/"$DOI_BACKUP_DIR"																				# Clone (bare) repo
	$GIT_COMMAND_PREFIX checkout --force																																							# Checkout files
	$GIT_COMMAND_PREFIX config --local status.showUntrackedFiles no																										# Hide untracked files
}

function restore_changes(){
	datetime=changes-$(date +%Y-%m-%d_%H-%M-%S)
	mkdir -p "$HOME"/Downloads/"$datetime"

	# Move changes to Downloads
	$GIT_COMMAND_PREFIX status --porcelain | while read -r line; do
		# Get file name and fire dir name
		file=$(echo "$line" | awk '{print $2}')
		fileDirectory=$(dirname "$file")

		# Create dir if not exist and move file
		mkdir -p "$HOME"/Downloads/"$datetime"/"$fileDirectory"
		mv "$HOME"/"$file" "$HOME"/Downloads/"$datetime"/"$file"

		# Restore file
		$GIT_COMMAND_PREFIX restore "$file"

		# Add log echo
		echo "$file" restore to default state
		echo "$(date +%Y-%m-%d_%H-%M-%S)" "$file" restore to default state >> "$HOME"/.logs
	done
}

function pull_changes(){
	$GIT_COMMAND_PREFIX pull --force
}

function push_changes(){
	date=$(date +%Y-%m-%d_%H-%M-%S)

	# Commit all changes
	$GIT_COMMAND_PREFIX commit -am "Backup update from $date"

	# Pull and push
	$GIT_COMMAND_PREFIX pull
	$GIT_COMMAND_PREFIX push
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

function save_env(){
	vars=$(set | grep -e "^DOI_")
	rm -f "$HOME"/.env
	for var in $vars; do
		echo "export $var" >> "$HOME"/.env
	done
}

# ======================== Main ========================

# Clone repo if not exist
if [[ ! -d "$HOME/$DOI_BACKUP_DIR" ]]; then
	clone_bare_repo
# else deal with existing repo (push or pull)
else
	# master
	if [[ "$DOI_BACKUP_MASTER" == "true" ]]; then
		push_changes
	# slave
	else
		# If there are changes?
		if [[ $($GIT_COMMAND_PREFIX status --porcelain | wc -l) -gt 0 ]]; then
			restore_changes
		fi

		# Pull changes
		pull_changes
	fi
fi

install_and_run_ansible
save_env

if [[ "$#" -eq 0 ]]; then
	/bin/bash
fi
