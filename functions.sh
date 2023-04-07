#!/bin/bash

function whereami() {
	echo -e "STY: \\033[0;31m$STY\\033[0m"
	ps wwf -s $$
}

function all_dirs() {
	if [ "$#" == "0" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$1" == "help" ]
	then
		echo "usage: all_dirs [SHELLCOMMANDS...]"
		echo "navigates to every folder in current directory"
		echo "and evals all given arguments there"
		return
	fi
	cwd="$(pwd)";
	for d in ./*/;
	do
		[ -e "$d" ] || continue

		echo -e "\\n$(tput bold)$d$(tput sgr0)\\n";
		cd "$d" || { echo "Error: $d failed"; return; }
		eval "$*";
		cd "$cwd" || { echo "Error: navigating back to $cwd failed"; return; }
	done;
}

# lopen - line open
# fuzzy find all lines and then open the matched line in vim
function lopen() {
	local search_path="${1:-.}"
	if [ ! -d "$search_path" ]
	then
		echo "Error: not a directory '$search_path'"
		return
	fi
	[[ -x "$(command -v fzf)" ]] || { echo "Error: you need fzf"; return; }
	[[ -x "$(command -v rg)" ]] || { echo "Error: you need rg"; return; }
	[[ -x "$(command -v vim)" ]] || { echo "Error: you need vim"; return; }

	local m
	if ! m="$(rg -n . "$search_path" | fzf)"
	then
		return
	fi
	local filename
	if ! filename="$(echo "$m" | cut -d":" -f1)"
	then
		return
	fi
	local line
	if ! line="$(echo "$m" | cut -d":" -f2)"
	then
		return
	fi
	if [[ ! "$line" =~ ^[0-9]+$ ]]
	then
		echo "Error: invalid line num '$line'"
		return
	fi
	if [ ! -f "$filename" ]
	then
		echo "Error: file not found '$filename'"
		return
	fi
	vim +"$line" -- "$filename"
	echo "" # fzf and rg could stderr and do weird offsets
	echo "[lopen] vim +$line -- $filename"
}

function fim() {
	# see also:
	# the alias fd for cd in dotfiles
	if [ ! -x "$(command -v fzf)" ]
	then
		echo "Error: fzf is not installed"
		return
	fi
	eval "vim $* $(fzf)"
}

