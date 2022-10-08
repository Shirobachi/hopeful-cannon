#!/bin/bash
# shellcheck disable=SC1091
set +e

sleep 5

export DISPLAY=:0
# load assets
if [[ ! -f "$HOME/Documents/Linux/Backup/assets.sh" ]]; then
	echo "Loading assets from remote "
	curl -s "https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/Backup/assets.sh" -o /tmp/assets.sh && source /tmp/assets.sh
else
	source "$HOME/Documents/Linux/Backup/assets.sh" # Load assets
fi
load_variables
prepend "$0"

notify-send "Last login information" "$(last reboot | head -2 | tail -1 | awk '{print $5" "$6" "$7", "$8$9$10" "$11}')"

append "$0"
