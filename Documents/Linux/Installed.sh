#!/bin/bash

# Exit if run as root
if [ "$(id -u)" = "0" ]; then
		echo "This script must not be run as root" 1>&2
		exit 1
fi

curl -s https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/super-duper-octo-spork.service -o /tmp/super-duper-octo-spork.service
sed -i "s,__HOME__,${HOME},g" /tmp/super-duper-octo-spork.service

Echo "Installing super-duper-octo-spork.service"
sudo cp /tmp/super-duper-octo-spork.service /etc/systemd/system/super-duper-octo-spork.service

Echo "Enabling super-duper-octo-spork.service"
sudo systemctl enable --now super-duper-octo-spork.service