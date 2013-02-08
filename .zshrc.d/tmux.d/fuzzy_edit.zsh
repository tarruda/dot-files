#!/usr/bin/env zsh
# Simple fuzzy file opener

ib_pos=(0 0)

# simple api for synchronizing render actions in the curses window
renderer() {
	zcurses string header "Fuzzy search: $1" 
	# reset positions
	zcurses move results 0 0
	zcurses move input_box 0 0
	zcurses refresh header results input_box
	exec 4>"$ipc_pipe"
	local cwd=`pwd`
	local cmd=
	local ib_pos=0
	local res_line=0
	local buffer=""
	while read cmd; do
		case "$cmd" in
			ECHO*)
				# echo character in the input window
				local char=${cmd#ECHO}
				zcurses char input_box $char
				ib_pos=$(($ib_pos + 1))
				buffer="$buffer$char"
				;;
			BACK)
				if [ $ib_pos -gt 0 ]; then
					# erase character in the input window
					zcurses move input_box 0 $(($ib_pos - 1))
					zcurses char input_box " "
					zcurses move input_box 0 $((--ib_pos))
					buffer=${buffer[1,-2]}
				fi
				;;
			RESULT*)
				if [ $res_line -lt 8 ]; then
					# adds line to result window
					local line=${${cmd#RESULT}#$cwd/}
					zcurses string results "$line"
					zcurses move results $((++res_line)) 0
				fi
				;;
			CLEAR)
				zcurses clear results
				zcurses move results 0 0
				res_line=0
				;;
			TXT)
				print -u 4 "$buffer"
				continue
				;;
		esac
		zcurses refresh results input_box
	done
	exec 4>&-
}

cleanup() {
	zcurses end
	_shm_pop "$wid:fuzzy-open" > /dev/null
	_shm_pop "$wid:fuzzy-running" > /dev/null
	exec 4<&-
	rm -f "$ipc_pipe"
	exit
}

split() {
	_shm_set "$wid:fuzzy-open" 1
	tmux split-window -t $wid -l 10\
		"zsh \"$HOME/.zshrc.d/tmux.d/fuzzy_edit.zsh\" $pid"
}

setup_screen() {
	zcurses init
	zcurses addwin header 1 $COLUMNS 0 0
	zcurses addwin results 8 $COLUMNS 1 0
	zcurses addwin input_box 1 $COLUMNS 9 0
}

getchar() {
	zcurses input input_box char
	keycode=`printf "%d" "'$char'"`
}

process_results() {
	local i=0
	local max=8
	local line=
	echo "CLEAR"
	while read line; do
		echo "RESULT$line"
		i=$(($i + 1))
		[[ $i -eq 8 ]] && break
	done
}

walk() {
	local cwd=$1
	local pattern=$2
	local matches=$3
	# explicitly associate the (#ia1) flag so it wont apply to
	# the negated patterns
	local fpattern="$cwd/(((#ia1)*${pattern}*)${PRUNE_REL_FILES})${PRUNE_FILES}(.N)"
	local dpattern="$cwd/(*${PRUNE_REL_DIRS})${PRUNE_DIRS}(/N)"
	for file in ${~fpattern}; do
		echo "RESULT$file"
		[ $((++matches)) -ge 8 ] && exit
	done
	for dir in ${~dpattern}; do
	  walk "$dir" "$pattern" "$matches"
	done
}

do_find() {
	rm -f /tmp/finder
	setopt extendedglob
	echo "CLEAR"
	walk "$1" "$2" 0
}

f_pid=""
process_char() {
	local dir="$1"
	case $keycode in
		127) echo "BACK" >&p ;;
		*) echo "ECHO$char" >&p ;;
	esac
	# if already running, kill the current finder before restarting
	kill $f_pid &> /dev/null
	if ps -p $f_pid &> /dev/null; then
		# finder still running
		if [ -z $waiting ]; then
			# signal that we are already waiting for a finder to exit
			waiting=1
			# only run one finder process at a time, and use another shell
			# to wait and start the finder again asynchronously
			(
			# since the finder is not a child of this shell, poll until it exits
			while ps -p $f_pid &>/dev/null; do 
				if ps -p $f_pid | grep -q 'defunct'; then
					break
				fi
				sleep 0.5
			done
			do_find "$dir" "`get_current_text`" >&p
			) &
		fi
	else
		unset waiting
		do_find "$dir" "`get_current_text`" >&p &
		f_pid=$!
	fi
}
 
get_current_text() {
	local txt=
	echo "TXT" >&p
	read -u 4 txt
	echo -n "$txt"
}

run() {
	zmodload zsh/curses
	zmodload zsh/pcre
	setopt rematchpcre
	trap cleanup INT HUP TERM EXIT
	# load ignored directories
	PRUNE_REL_DIRS=""
	PRUNE_REL_FILES=""
	PRUNE_DIRS=""
	PRUNE_FILES=""
	local dir="$PWD"
	if [ -r "$dir/.fuzzy_ignore" ]; then
		exec 3<"$dir/.fuzzy_ignore"
		while read -u 3 pat; do
			# strip line comments in the ignore file
			pat="${pat%%\#*}"
			[ -z $pat ] && echo "abc" > /tmp/finder && continue
			if [ "$pat" -pcre-match ^/ ]; then
				# relative to the base directory
				if [ "$pat" -pcre-match /$ ]; then
					PRUNE_DIRS="$PRUNE_DIRS~$dir${pat%/}"
				else
					PRUNE_FILES="$PRUNE_FILES~$dir$pat"
				fi
			else
				# relative to the current directory being scanned
				if [ "$pat" -pcre-match /$ ]; then
					PRUNE_REL_DIRS="$PRUNE_REL_DIRS~${pat%/}"
				else
					PRUNE_REL_FILES="$PRUNE_REL_FILES~$pat"
				fi
			fi
		done
		exec 3>&-
	fi
	export PRUNE_DIRS PRUNE_FILES PRUNE_REL_DIRS PRUNE_REL_FILES
	#
	setup_screen
	export ipc_pipe=`mktemp -u`
	while ! mkfifo -m 600 "$ipc_pipe" &>/dev/null; do
		export ipc_pipe=`mktemp -u`
	done
	_shm_set "$wid:fuzzy-running" "${TMUX_PANE#*\%}"
	{ coproc renderer "$dir" >&3 } 3>&1
	exec 4<"$ipc_pipe"
	getchar
	while true; do
		if [ $keycode != 27 ]; then
			process_char "$dir"
		else
			break
		fi
		getchar
	done
}

source "$HOME/.zshrc.d/tmux.d/common.zsh"

pid=$1
wid="`tmux display-message -pt \"$pid\" '#{window_id}'`" 2>/dev/null
if [ -z $wid ]; then
	echo "Cannot find window"
	exit
fi
is_open="`_shm_get $wid:fuzzy-open`"
if [ -z $is_open ]; then
	split
else
	pane_id="`_shm_get $wid:fuzzy-running`"
	if [ "%$pane_id" != "$TMUX_PANE" ]; then
		run
	fi
fi
