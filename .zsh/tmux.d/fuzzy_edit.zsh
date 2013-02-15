#!/usr/bin/env zsh

RESULTS_HEIGHT=$(($LINES - 2))
# Simple fuzzy file finder, useful for quickly opening files by typing only
# parts of the name

run() {
	setup
	trap cleanup INT TERM EXIT
	getchar
	while true; do
		if [ $KEYCODE != 27 ]; then
			process_char
		else
			break
		fi
		getchar
	done
}

setup() {
	zmodload zsh/curses
	zmodload zsh/pcre
	setopt rematchpcre
	export CWD="`pwd`"
	setup_ipc
	setup_ignore_patterns
	setup_screen
	# initialize renderer process
	{ coproc renderer >&3 } 3>&1
	# Open INPUT_IPC for reading the currently typed text
	exec 4<"$INPUT_IPC"
}

setup_ipc() {
	# This pipe is used for reading the currently typed text
	export INPUT_IPC=`mktemp -u`
	while ! mkfifo -m 600 "$INPUT_IPC" &>/dev/null; do
		export INPUT_IPC=`mktemp -u`
	done
}

setup_ignore_patterns() {
	PRUNE_REL_DIRS=""
	PRUNE_REL_FILES=""
	PRUNE_DIRS=""
	PRUNE_FILES=""
	if [ -r "$CWD/.fuzzy_ignore" ]; then
		exec 3<"$CWD/.fuzzy_ignore"
		while read -u 3 pat; do
			# strip line comments in the ignore file
			pat="${pat%%\#*}"
			[ -z $pat ] && continue
			if [ "$pat" -pcre-match ^/ ]; then
				# relative to the base directory
				if [ "$pat" -pcre-match /$ ]; then
					PRUNE_DIRS="$PRUNE_DIRS~$CWD${pat%/}"
				else
					PRUNE_FILES="$PRUNE_FILES~$CWD$pat"
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
}

setup_screen() {
	zcurses init
	zcurses addwin header 1 $COLUMNS 0 0
	zcurses addwin results $RESULTS_HEIGHT $COLUMNS 1 0
	zcurses addwin input_box 1 $COLUMNS $(($RESULTS_HEIGHT + 1)) 0
}

# Runs in a coproc shell and provides a simple protocol for executing
# and serializing render actions to the terminal. It is also used to
# read the currently typed text
renderer() {
	zcurses string header "Fuzzy search: $CWD" 
	# reset positions
	zcurses move results 0 0
	zcurses move input_box 0 0
	zcurses refresh header results input_box
	exec 4>"$INPUT_IPC"
	local cmd=
	local ib_pos=0
	local res_line=0
	local buffer=""
	while read cmd; do
		case "$cmd" in
			ECHO*)
				# echo character in the input window
				local char="${cmd#ECHO}"
				zcurses char input_box "$char"
				ib_pos=$(($ib_pos + 1))
				buffer="$buffer$char"
				zcurses clear header
				zcurses string header "Fuzzy search: $buffer" 
				;;
			BACK)
				if [ $ib_pos -gt 0 ]; then
					# erase character in the input window
					zcurses move input_box 0 $(($ib_pos - 1))
					zcurses char input_box " "
					zcurses move input_box 0 $((--ib_pos))
					buffer=${buffer[1,-2]}
					zcurses clear header
					zcurses string header "Fuzzy search: $buffer" 
				fi
				;;
			RESULT*)
				if [ $res_line -lt $RESULTS_HEIGHT ]; then
					# adds line to result window
					local line=${${cmd#RESULT}#$CWD/}
					zcurses string results "$line"
					zcurses move results $((++res_line)) 0
				fi
				;;
			CLEAR)
				# clear the results
				zcurses clear results
				zcurses move results 0 0
				res_line=0
				;;
			GET)
				print -u 4 "$buffer"
				continue
				;;
		esac
		zcurses refresh header results input_box
	done
	exec 4>&-
}

cleanup() {
	zcurses end
	exec 4<&-
	rm -f "$INPUT_IPC"
	exit
}

# Reads a single char and sets the char keycode
getchar() {
	zcurses input input_box CHAR
	KEYCODE=`printf "%d" "'$CHAR'"`
}

process_char() {
	case $KEYCODE in
		127) echo "BACK" >&p ;;
		*) echo "ECHO$CHAR" >&p ;;
	esac
	# if already running, kill the current finder before restarting
	kill $FIND_PID &> /dev/null
	if kill -0 $FIND_PID &> /dev/null; then
		# finder still running
		if [ -z $WAITING ]; then
			# signal that we are already waiting for a finder to exit
			WAITING=1
			# only run one finder process at a time, and use another shell
			# to wait and start the finder again asynchronously
			(
			# since the finder is not a child of this shell, poll until it exits
			while kill -0 $FIND_PID &> /dev/null; do 
				if ps -p $FIND_PID | grep -q 'defunct'; then
					break
				fi
				sleep 0.5
			done
			find "`get_current_text`" >&p
			) &
		fi
	else
		# unset WAITING
		find "`get_current_text`" >&p &
		FIND_PID=$!
	fi
}

# queries the 
get_current_text() {
	local text=
	echo "GET" >&p
	read -u 4 text
	echo -n "$text"
}

# Delegates the actual finding to the 'walk' function. This runs aynchronously
# in a background process
find() {
	setopt extendedglob
	echo "CLEAR"
	walk "$CWD" "$1" 0
	sleep 5
}

walk() {
	local cwd=$1
	local pattern=$2
	local matches=$3
	# explicitly set the scope of the '#ia1' flag so it wont apply to
	# the negated patterns
	local fpattern="$cwd/(((#ia1)*${pattern}*)${PRUNE_REL_FILES})${PRUNE_FILES}(.N)"
	local dpattern="$cwd/(*${PRUNE_REL_DIRS})${PRUNE_DIRS}(/N)"
	for file in ${~fpattern}; do
		echo "RESULT$file"
		[ $((++matches)) -ge $RESULTS_HEIGHT ] && sleep 5 && exit
	done
	for dir in ${~dpattern}; do
	  walk "$dir" "$pattern" "$matches"
	done
}

run
