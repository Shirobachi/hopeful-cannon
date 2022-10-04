#!/bin/bash
# shellcheck disable=SC1090

# INFO: Save all variables with prefix "$2" to file "$1"
# $1 - file to save variables to
# $2 - variables prefix to save
function save_variables(){
	ENV_FILE=${1:-"$HOME/Documents/Linux/.env"}
	VARIABLES_PREFIX=${2:-"DOI_"}

	rm "$ENV_FILE" 2> /dev/null
	variables=$(set | grep -e "^$VARIABLES_PREFIX")

	for variable in $variables; do
		echo export "$variable" >> "$ENV_FILE"
	done
}

# INFO: Load all variables from file "$1"
# $1 - file to load variables from
function load_variables(){
	ENV_FILE=${1:-"$HOME/Documents/Linux/.env"}

	if [[ -f $ENV_FILE ]]; then
		. "$ENV_FILE"
	fi
}