#! /bin/bash
set -e # Exit on error

# install ansible 
. /etc/os-release
if [[ "$ID" == "manjaro" ]]; then
	sudo pacman -Syu --noconfirm --needed ansible
fi

# clone backup repo (bare)
BACKUP_DIR="$HOME"/.backup
# echo ".cfg" >> .gitignore &&   TODO
git clone --bare https://github.com/Shirobachi/super-duper-octo-spork.git "$BACKUP_DIR" 	# cloning
git --git-dir="$BACKUP_DIR" --work-tree="$HOME" checkout --force 							# applying

# run ansible set up playbook
ansible-playbook -c local -i localhost, "$HOME"/Documents/Linux/Installer/update.yml
