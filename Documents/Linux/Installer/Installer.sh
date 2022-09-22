#! /bin/bash

# Load system information
# shellcheck disable=SC1091
. /etc/os-release

link=https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/Installer/playbook-"$ID$VERSION_ID".yml
if ! curl -Is "$link" | head -1 | grep -q '20'; then
	echo "$ID $VERSION_ID is not supported!"
	exit 1
fi
# Install packages
PACHAGES="git"
PACHAGES_UBUNTU=""
PACHAGES_ARCH="cronie"
if ! which crontab; then
	if [[ "$ID" == "ubuntu" ]]; then
		sudo apt install -y "$PACHAGES $PACHAGES_UBUNTU"
	elif [[ "$ID" == "arch" ]] || [[ "$ID" == "manjaro" ]]; then
		sudo pacman -Syu --noconfirm "$PACHAGES $PACHAGES_ARCH"
	fi
fi

# Download bare repo
BACKUP_DIR="$HOME"/.backup
# echo ".cfg" >> .gitignore &&   TODO
git clone --bare https://github.com/Shirobachi/super-duper-octo-spork.git "$BACKUP_DIR"
git --git-dir="$BACKUP_DIR" --work-tree="$HOME" checkout --force 

# init crontab
echo "0 0 * * * $HOME/Documents/Linux/Installer/update.sh" | crontab -
