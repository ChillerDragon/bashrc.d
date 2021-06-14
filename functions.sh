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

