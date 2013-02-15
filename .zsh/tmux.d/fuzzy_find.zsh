#!/usr/bin/env zsh
# Simple interactive fuzzy file finder, useful for quickly opening files in
# a 'project directory' by only typing parts of the name


# Action to be executed on the selected filename
ACTION=$1
if [ -z $ACTION ]; then
	# By default, edit the file
	ACTION="$EDITOR"
fi
# Number of errors allowed when doing approximate matching
ERRORS_ALLOWED=$2
if [ -z $ERRORS_ALLOWED ]; then
	ERRORS_ALLOWED=1
fi
# Number of result windows
RESULTS_HEIGHT=$(($LINES - 2))
# working dir
CWD="`pwd`"
# share this info with background jobs
export ACTION ERRORS_ALLOWED RESULTS_HEIGHT CWD

run() {
	setup
	trap 'cleanup; exit' EXIT INT TERM
	find "" >&p &
	FIND_PID=$!
	getchar
	while true; do
		process_char
		getchar
	done
}

setup() {
	zmodload zsh/curses
	zmodload zsh/pcre
	setopt rematchpcre
	setup_ipc
	setup_ignore_patterns
	setup_screen
	# initialize renderer process
	{ coproc renderer >&3 } 3>&1
	# Open INPUT_IPC for reading the currently typed text
	exec 4<"$INPUT_IPC"
}

setup_ipc() {
	# This pipe is used for reading the currently typed text/selected file
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
	# put each result in its own window, this makes easy to highlight lines
	local i=
	for i in {1..$RESULTS_HEIGHT}; do
		zcurses addwin "results_$i" 1 $COLUMNS $i 0
	done
	# zcurses addwin results $RESULTS_HEIGHT $COLUMNS 1 0
	zcurses addwin input_box 1 $COLUMNS $(($RESULTS_HEIGHT + 1)) 0
}

# Runs in a coproc shell and provides a simple protocol for executing
# and serializing render actions to the terminal. It is also used to
# read the currently typed text/selected file
renderer() {
	zcurses string header "Fuzzy search: $CWD" 
	# reset positions
	zcurses move input_box 0 0
	zcurses refresh header input_box
	exec 4>"$INPUT_IPC"
	local cmd=
	local ib_pos=0
	local selected_line=
	local sel_pos=
	local sel_buffer=
	local sel_char=
	local res_line=$RESULTS_HEIGHT
	local buffer=""
	local win=
	local line=
	local i=
	while read cmd; do
		case "$cmd" in
			ECHO*)
				# echo character in the input window
				local char="${cmd#ECHO}"
				zcurses char input_box "$char"
				ib_pos=$(($ib_pos + 1))
				buffer="$buffer$char"
				;;
			BACKSPACE)
				if [ $ib_pos -gt 0 ]; then
					# erase character in the input window
					zcurses move input_box 0 $(($ib_pos - 1))
					zcurses char input_box " "
					zcurses move input_box 0 $((--ib_pos))
					buffer=${buffer[1,-2]}
				fi
				;;
			SPACE)
				zcurses char input_box " "
				ib_pos=$(($ib_pos + 1))
				buffer="$buffer "
				;;
			UP)
				if [ $selected_line -gt $(($res_line + 1)) ]; then
					win="results_$selected_line"
					zcurses bg $win default/default
					zcurses refresh $win
					selected_line=$(($selected_line - 1))
					win="results_$selected_line"
					zcurses bg $win black/white
					zcurses refresh $win
				fi
				;;
			DOWN)
				if [ $selected_line -lt $RESULTS_HEIGHT ]; then
					win="results_$selected_line"
					zcurses bg $win default/default
					zcurses refresh $win
					selected_line=$(($selected_line + 1))
					win="results_$selected_line"
					zcurses bg $win black/white
					zcurses refresh $win
				fi
				;;
			ENTER)
				win="results_$selected_line"
				# save the current cursor position on the selected line/window
				zcurses position $win sel_pos
				# query all chars from 0 to the cursor pos
				sel_buffer=""
				for i in {0..$(($sel_pos[2] - 1))}; do
					zcurses move $win 0 $i
					zcurses querychar $win sel_char
					sel_buffer="${sel_buffer}${sel_char[1]}"
				done
				zcurses move $win 0 $sel_pos[2]
				print -u 4 "$CWD/$sel_buffer"
				;;
			RESULT*)
				if [ $res_line -ge 1 ]; then
					win="results_$res_line"
					# adds line to result window
					line=${${cmd#RESULT}#$CWD/}
					if [ $res_line -eq $RESULTS_HEIGHT ]; then
						# Always highlight the first result
						zcurses bg $win black/white
						selected_line=$res_line
					fi
					zcurses string $win "$line"
					zcurses refresh $win
					res_line=$(($res_line - 1))
				fi
				;;
			CLEAR)
				# clear the results
				res_line=$RESULTS_HEIGHT
				for i in {1..$RESULTS_HEIGHT}; do
					win="results_$i"
					zcurses clear $win
					zcurses bg $win default/default
					zcurses move $win 0 0
					zcurses refresh $win
				done
				;;
			GET)
				print -u 4 "$buffer"
				continue
				;;
		esac
		# Always keep the cursor focused on the input window
		zcurses refresh input_box
	done
	exec 4>&-
}

cleanup() {
	rm -f "$INPUT_IPC"
	zcurses end
}

# Reads a single char and sets the char keycode
getchar() {
	zcurses input input_box CHAR KEY
	KEYCODE=`printf "%d" "'$CHAR'"`
}

process_char() {
	case $KEYCODE in
		10)
			local file=
		 	echo "ENTER" >&p
			read -u 4 file
			cleanup
			exec eval "$ACTION \"$file\""
		 	;;
		27)
			exit
			;;
		32)
		 	echo "SPACE" >&p
			reset_find
		 	;;
		127)
		 	echo "BACKSPACE" >&p
			reset_find
		 	;;
		*)
			if [ -n "$CHAR" ]; then
				echo "ECHO$CHAR" >&p
				reset_find
			elif [ -n "$KEY" ]; then
				echo "$KEY" >&p
			fi
			;;
	esac
}

reset_find() {
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
				sleep 0.1
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

# Delegates the actual finding to the 'walk' function. This runs as a background job
find() {
	setopt extendedglob
	echo "CLEAR"
	if [ -n "$1" ]; then
		walk "$CWD" "$1" 0
	else
		walk "$CWD" "" 0
	fi
	sleep 5
}

walk() {
	local cwd=$1
	local pattern=$2
	local matches=$3
	# explicitly set the scope of the '#ia1' flag so it wont apply to
	# the negated patterns
	local fpattern=
	if [ -n "$pattern" ]; then
		fpattern="$cwd/(((#ia$ERRORS_ALLOWED)*${pattern}*)${PRUNE_REL_FILES})${PRUNE_FILES}(.N)"
	else
		fpattern="$cwd/(*${PRUNE_REL_FILES})${PRUNE_FILES}(.N)"
	fi
	local dpattern="$cwd/(*${PRUNE_REL_DIRS})${PRUNE_DIRS}(/N)"
	for file in ${~fpattern}; do
		echo "RESULT$file"
		# no need to keep searching after the screen is filled with results
		[ $((++matches)) -ge $RESULTS_HEIGHT ] && sleep 5 && exit
	done
	for dir in ${~dpattern}; do
	  walk "$dir" "$pattern" "$matches"
	done
}

run
