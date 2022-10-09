#!/bin/bash
# shellcheck disable=SC1090

DEFAULT_DOI_VARIABLE_FILE="$HOME/Documents/Linux/Backup/.env"

# INFO: Save all variables with prefix "$2" to file "$1"
# $1 - file to save variables to
# $2 - variables prefix to save
function save_variables(){
	ENV_FILE=${1:-"$DEFAULT_DOI_VARIABLE_FILE"}
	VARIABLES_PREFIX=${2:-"DOI_"}

	mkdir -p "$(dirname "$ENV_FILE")"
	rm "$ENV_FILE" 2> /dev/null
	variables=$(set | grep -e "^$VARIABLES_PREFIX")

	for variable in $variables; do
		echo export "$variable" >> "$ENV_FILE"
	done
}

# INFO: Load all variables from file "$1"
# $1 - file to load variables from
function load_variables(){
	ENV_FILE=${1:-"$DEFAULT_DOI_VARIABLE_FILE"}

	if [[ -f $ENV_FILE ]]; then
		. "$ENV_FILE"
	fi
	export DOI_BACKUP_DIR=${DOI_BACKUP_DIR:-"$HOME/.backup"}
	export DOI_BACKUP_REPO=${DOI_BACKUP_REPO:-"Shirobachi/super-duper-octo-spork"}
	export DOI_BACKUP_MODE=${DOI_BACKUP_MODE:-"slave"}
}

# INFO: Run script same as $1 but with .prepend/.override sufix
# $1 - script name
function prepend(){
	if [[ "$#" -ne 1 ]]; then
		exit 1
	fi

	if [[ -f "$(dirname "$1")/$(basename "$1").prepend" ]]; then
		source "$(dirname "$1")/$(basename "$1").prepend"
	fi

	if [[ -f "$(dirname "$1")/$(basename "$1").overwrite" ]]; then
		source "$(dirname "$1")/$(basename "$1").overwrite"
		exit 0 # Exit if overwrite
	fi
}

# INFO: Run prepend function
function overwrite(){
	prepend "$@"
}

# INFO: Run script same as $1 but with .append sufix
# $1 - script name
function append(){
	if [[ "$#" -ne 1 ]]; then
		exit 1
	fi

	if [[ -f "$(dirname "$1")/$(basename "$1").append" ]]; then
		source "$(dirname "$1")/$(basename "$1").append"
	fi
}

# INFO: Function update screens via xrander
function updateScreen(){
	# Use arandr to generate this script file
	xrandr | grep -vi primary | grep "disconnected" | awk '{print $1}' | xargs -I{} xrandr --output {} --off

	if [[ -f "$HOME"/Documents/Linux/Backup/screen-layout.sh ]]; then
		"$HOME"/Documents/Linux/Backup/screen-layout.sh

		# Assign workspaces to screens
		screens=$(xrandr | grep " connected" | grep -iv primary | awk '{print $1}')
		if [[ $(echo "$screens" | wc -l ) -eq 1 ]] || [[ $(echo "$screens" | wc -l ) -eq 2 ]]; then
			i3-msg "workspace L; move workspace to output $(echo "$screens" | head -1);"
			if [[ $(echo "$screens" | wc -l ) -eq 2 ]]; then
				sleep 2
				i3-msg "workspace R; move workspace to output $(echo "$screens" | tail -1)"
			fi
		fi
	fi
}

function runDockers(){
	cd "$HOME/Documents/Linux/Docker" || exit 1

	for file in *.yml; do
		docker-compose -f "$file" up -d
	done
}

function saveLayout(){
	workspaces=$(i3-msg -t get_workspaces | jq -r '.[].name')
	echo "$workspaces"
	rm -rf /tmp/i3-resurrect

	for workspace in $workspaces; do
		i3-resurrect save -w "$workspace" -d /tmp/i3-resurrect/
	done
}

function restoreLayout(){
	# check if /tmp/i3-resurrect exists and not empty
	if [[ -d /tmp/i3-resurrect && "$(ls -A /tmp/i3-resurrect)" ]]; then
		for workspace in /tmp/i3-resurrect/*layout.json; do
			i3-resurrect restore -w "$(basename "$workspace" | awk -F_ '{print $2}')" -d /tmp/i3-resurrect/
		done
	fi
}

function powermenu(){
	# shellcheck disable=SC2034
	OPTIONS="Logout\nReboot\nPoweroff"
	CHOICE=$(echo -e "$OPTIONS" | dmenu -i -p "Power Menu" | awk '{print tolower($0)}')

	saveLayout
	killall chrome || true
	notify-send "Power Menu" "Saving layout and killing chrome, $CHOICE in 5 seconds"
	sleep 5

	if [[ "$CHOICE" = "logout" ]]; then
		i3-msg exit
	else
		systemctl "$CHOICE"
	fi
}

# # # # # # # # # # Runners # # # # # # # # # #

# iNFO: Run function if passed as $1
if [[ "$#" -eq 1 ]] && echo "$1" | grep -qv "-"; then
	functions=$(grep -e "^function " "$0" | awk '{print $2}' | sed 's/()//g')
	if echo "$functions" | grep -q "$1"; then
		"$1"
	fi
fi