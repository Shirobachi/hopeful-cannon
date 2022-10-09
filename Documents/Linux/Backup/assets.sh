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
	xrandr | grep -vi primary | grep "disconnected" | awk '{print $1}' | xargs -I{} xrandr --output {} --off && "$HOME"/Documents/Linux/Backup/screen-layout.sh
}

function runDockers(){
	cd "$HOME/Documents/Linux/Docker" || exit 1

	for file in *.yml; do
		docker-compose -f "$file" up -d
	done
}

function saveLayout(){
	workspaces=$(i3-msg -t get_workspaces | jq -r '.[].name')
	rm -rf /tmp/i3-resurrect

	for workspace in $workspaces; do
		i3-resurrect save -w "$workspace" -d /tmp/i3-resurrect/
	done
}

function restoreLayout(){
	for workspace in /tmp/i3-resurrect/*layout.json; do
		i3-resurrect restore -w "$(basename "$workspace" | awk -F_ '{print $2}')" -d /tmp/i3-resurrect/
	done
}

# # # # # # # # # # Runners # # # # # # # # # #

# iNFO: Run function if passed as $1
functions=$(declare -F | awk '{print $NF}' | sort | grep -ve "^_" )
if [[ "$#" -eq 1 ]] && echo "$1" | grep -qv "-" && echo "$functions" | grep -q "$1"; then
	$1
fi