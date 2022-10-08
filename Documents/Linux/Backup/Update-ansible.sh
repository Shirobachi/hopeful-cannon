#!/bin/bash
# shellcheck disable=SC1091
set -e # Exit with nonzero exit code if anything fails

# load assets
if [[ ! -f "$HOME/Documents/Linux/Backup/assets.sh" ]]; then
	echo "Loading assets from remote "
	curl -s "https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/Backup/assets.sh" -o /tmp/assets.sh && source /tmp/assets.sh
else
	source "$HOME/Documents/Linux/Backup/assets.sh" # Load assets
fi
load_variables
BACKUP_GIT_HTTPS_REPO="https://github.com/$DOI_BACKUP_REPO.git"

echo "Installing and running ansible..."
. /etc/os-release
if [[ "$ID_LIKE" == "arch" ]]; then
	sudo pacman -Syu --noconfirm --needed ansible
else
	echo "Unsupported OS"
	exit 0
fi

# if $1 parameter is test, --test, t or -t then run ansible in check mode
if [[ $1 == "test" ]] || [[ $1 == "-t" ]] || [[ $1 == "--test" ]] || [[ $1 == "t" ]]; then
	echo "Running ansible in check mode"
	ansible-playbook -i localhost "$HOME/Documents/Linux/Backup/Update.yml" --check
	exit 0
fi

# if any parameter is local, --local, l or -l then run ansible in local mode
if [[ $1 == "local" ]] || [[ $1 == "-l" ]] || [[ $1 == "--local" ]] || [[ $1 == "l" ]]; then
	echo "Running ansible in local mode"
	if [[ "$#" -eq 1 ]]; then
		ansible-playbook -i localhost "$HOME/Documents/Linux/Backup/Update.yml" --connection=local
	elif [[ "$#" -eq 2 ]]; then
		ansible-playbook -i localhost "$HOME/Documents/Linux/Backup/Update.yml" --connection=local  --tags "$2"
	else
		echo "Too many parameters"
		echo "Usage: $0 [[-]local|l] [tag]"
		exit 1
	fi

	exit 0
fi

# Run ansible playbook in pull mode
ansible-pull -U "$BACKUP_GIT_HTTPS_REPO" Documents/Linux/Backup/Update.yml --purge