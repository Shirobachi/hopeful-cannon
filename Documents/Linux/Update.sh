#!/bin/bash

# exit if not root
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

/usr/bin/tty -s && INTERACTIVE=true || INTERACTIVE=false
SLEEP_TIME=${1:-3600}

while true; do
	sudo -H -u simon bash -c "$(dirname "$0")/Update-backup.sh"
	"$(dirname "$0")/Update-ansible.sh"

	if [[ "$INTERACTIVE" = true ]]; then
		break;
	else
		echo "Sleeping for $SLEEP_TIME seconds ..."
		sleep "$SLEEP_TIME"
	fi
done