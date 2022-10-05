#!/bin/bash
set -e # Exit with nonzero exit code if anything fails
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



# if any parameter is test, --test, t or -t then run ansible in check mode
for i in "$@"; do
	if [[ $i == "test" ]] || [[ $i == "-t" ]] || [[ $i == "--test" ]] || [[ $i == "t" ]]; then
		echo "Running ansible in check mode"
		ansible-playbook -i localhost "$HOME/Documents/Linux/Update.yml" --check
		exit 0
	fi
done

# if any parameter is local, --local, l or -l then run ansible in local mode
for i in "$@"; do
	if [[ $i == "local" ]] || [[ $i == "-l" ]] || [[ $i == "--local" ]] || [[ $i == "l" ]]; then
		echo "Running ansible in local mode"
		ansible-playbook -i localhost "$HOME/Documents/Linux/Update.yml" --connection=local
		exit 0
	fi
done

# Run ansible playbook in pull mode
ansible-pull -U "$BACKUP_GIT_HTTPS_REPO" Documents/Linux/Update.yml --purge