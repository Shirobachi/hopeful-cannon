#! /bin/bash
set -e # Exit on error

# install ansible 
. /etc/os-release
if [[ "$ID" == "manjaro" ]]; then
	sudo pacman -Syu --noconfirm --needed ansible
else
	echo "Unsupported OS"
	exit 1
fi

# clone backup repo (bare)
BACKUP_DIR=backup
echo ".$BACKUP_DIR" >> .gitignore
git clone --bare https://github.com/Shirobachi/super-duper-octo-spork.git "$HOME"/."$BACKUP_DIR"
git --git-dir="$HOME"/."$BACKUP_DIR" --work-tree="$HOME" checkout --force
git --git-dir="$HOME"/."$BACKUP_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no

# run ansible set up playbook
ansible-playbook -c local -i localhost, "$HOME"/Documents/Linux/Installer/update.yml
