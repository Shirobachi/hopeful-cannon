#!/bin/bash
# shellcheck disable=SC1091

# load assets
if [[ ! -f "$HOME/Documents/Linux/assets.sh" ]]; then
	echo "Loading assets from remote "
	curl -s "https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/assets.sh" -o /tmp/assets.sh && source /tmp/assets.sh
else
	source "$HOME/Documents/Linux/assets.sh" # Load assets
fi
load_variables
BACKUP_GIT_HTTPS_REPO="https://github.com/$DOI_BACKUP_REPO.git"

echo "Installing and running ansible..."
. /etc/os-release
if [[ "$ID" == "manjaro" ]]; then
	sudo pacman -Syu --noconfirm --needed ansible
else
	echo "Unsupported OS"
	exit 0
fi

# Run ansible playbook in pull mode
ansible-pull -U "$BACKUP_GIT_HTTPS_REPO" Documents/Linux/Update.yml --purge