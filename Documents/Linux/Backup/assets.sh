#!/bin/bash
# shellcheck disable=SC1090

DEFAULT_DOI_VARIABLE_FILE="$HOME/Documents/Linux/Backup/.env"
WOSKPACE_LAYOUT_PATH="$HOME/.cache/workspace-layout/"

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

# INFO: Save workspace layout
function saveLayout(){
	rm -rf "$WOSKPACE_LAYOUT_PATH"
	workspaces=$(i3-msg -t get_workspaces | jq -r '.[].name')

	for workspace in $workspaces; do
		i3-resurrect save -w "$workspace" -d "$WOSKPACE_LAYOUT_PATH"
	done
}

# INFO: Restore workspace layout
function restoreLayout(){
	# check if $WOSKPACE_LAYOUT_PATH exists and not empty
	if [[ -d "$WOSKPACE_LAYOUT_PATH" && "$(ls -A "$WOSKPACE_LAYOUT_PATH")" ]]; then
		for workspace in "$WOSKPACE_LAYOUT_PATH"*layout.json; do
			i3-resurrect restore -w "$(basename "$workspace" | awk -F_ '{print $2}')" -d "$WOSKPACE_LAYOUT_PATH"
		done
	fi
}

# INFO: Show menu for manage system
function powermenu(){
	# shellcheck disable=SC2034
	LOCK_COMMAND=$(grep "mod+l" "$HOME/.config/i3/config" | awk -F"exec" '{print $2}')
	[[ -z "$LOCK_COMMAND" ]] && LOCK_COMMAND="i3lock -c 216485"

	OPTIONS="Logout\nSuspend\nReboot\nPoweroff"
	CHOICE=$(echo -e "$OPTIONS" | dmenu -i -p "Power Menu" | awk '{print tolower($0)}')

	if [[ -n "$CHOICE" ]]; then
		saveLayout
		notify-send "System" "System will be $CHOICE in 5 seconds ..." 
		sleep 5

		[[ $CHOICE = "suspend" ]] && eval $LOCK_COMMAND
		if [[ "$CHOICE" = "logout" ]]; then
			i3-msg exit
		else
			systemctl "$CHOICE"
		fi
	fi
}

function test () {
	allScreens=$(xrandr | grep " connected" | awk '{print $1}')
}

# # # # # # # # # # Runner # # # # # # # # # #

# iNFO: Run function if passed as $1
if [[ "$#" -eq 1 ]] && echo "$1" | grep -qv "-"; then
	functions=$(grep -e "^function " "$0" | awk '{print $2}' | sed 's/()//g')
	if echo "$functions" | grep -q "$1"; then
		"$1"
	else
		echo "Function $1 not found"
		exit 1
	fi
fi