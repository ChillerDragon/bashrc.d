#!/bin/bash

x() {
	ls
	if [ -d .hg ]
	then
		hg status
	fi
	if [ -d .git ]
	then
		git status
	fi
}

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
	local cmd
	cmd="vim +$line -- $filename"
	vim +"$line" -- "$filename"
	echo "" # fzf and rg could stderr and do weird offsets
	echo "[lopen] $cmd"
	history -s "$cmd"
}

function fim() {
	# see also:
	if [ ! -x "$(command -v fzf)" ]
	then
		echo "Error: fzf is not installed"
		return
	fi
	eval "vim $* $(fzf)"
}

function check_cert() {
        if [ "$#" != "1" ]
        then
                echo "usage: check_cert url"
                echo "description:"
                echo "  prints ssl cert expire date of given url"
                return
        fi
        local url="$1"
        curl -vvvi "$url" 2>&1 | grep "expire date" -A1
}

function dd7() {
	if [ ! -x "$(command -v DDNet7)" ]
	then
		echo "Error: DDNet7 not in PATH"
		echo "       git clone git@github.com:ChillerDragon/ddnet --recursive"
		echo "       cd ddnet && git checkout pr_07_client"
		echo "       mkdir build && cd build && cmake .. && make"
		echo "       sudo cp DDNet /usr/local/bin/DDNet7"
		return
	fi

	local rundir="$HOME/Desktop/git/ddnet/build"
	if [ -d "$rundir" ] && [ -d "$rundir/data" ]
	then
		cd "$rundir" || return
	fi

	_dd7_usage() {
		echo "usage: dd7 [FLAGS..] [tw cmd] [FLAGS..]"
		echo "flags:"
		echo "  --help | -h       show this help"
		echo "  --dev             run ./DDNet instead of DDNet7 binary"
	}

	if [ "$1" == "-h" ] || [ "$1" == "--help" ]
	then
		_dd7_usage
		return
	fi

	local tw_bin=DDNet7
	local cmd_string=''
	local arg
	while true
	do
		[[ "$#" -gt "0" ]] || break

		arg="$1"
		shift

		if [ "${arg::1}" == "-" ]
		then
			if [ "$arg" == "--dev" ]
			then
				tw_bin=./DDNet
			elif [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
			then
				_dd7_usage
				return
			else
				_dd7_usage
				echo "Unknown flag: $arg"
				return 1
			fi
		elif [ "$cmd_string" == "" ]
		then
			cmd_string="$arg"
		else
			_dd7_usage
			echo "Unexpected argument: $arg"
			return 1
		fi
	done

	local cmd
	local cmd_string7=''
	while read -r cmd
	do
		if [ "$cmd" == "connect localhost" ]
		then
			cmd="connect tw-0.7+udp://127.0.0.1"
		elif [[ "$cmd" == "connect "* ]] && ! [[ "$cmd" == "connect tw-0.7+udp://"* ]]
		then
			cmd="connect tw-0.7+udp://${cmd:8}"
		fi
		cmd_string7+="$cmd;"
	done < <(echo "$cmd_string" | tr ';' '\n')
	echo "[dd7] got: $cmd_string"
	echo "[dd7] translated to: $cmd_string7"
	"$tw_bin" "$cmd_string7"
}

