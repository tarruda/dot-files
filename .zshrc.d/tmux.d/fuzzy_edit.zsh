#!/usr/bin/env zsh
# Simple fuzzy file opener

ib_pos=(0 0)

# simple api for synchronizing render actions in the curses window
renderer() {
	zcurses string header "Fuzzy search"
	# reset positions
	zcurses move results 0 0
	zcurses move input_box 0 0
	zcurses refresh header results input_box
	exec 4>"$ipc_pipe"
	local cmd=
	local ib_pos=0
	local res_line=0
	local buffer=""
	while read cmd; do
		case $cmd in
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
					local line=${cmd#RESULT}
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
		zcurses clear header
		zcurses string header "Fuzzy search: $buffer"
		zcurses refresh header results input_box
	done
	exec 4>&-
}

cleanup() {
	zcurses end
	_shm_pop "$wid:fuzzy-open" > /dev/null
	_shm_pop "$wid:fuzzy-running" > /dev/null
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

f_pid=
process_char() {
	if [ $keycode = 127 ]; then
		# backspace
		echo "BACK" >&p
	else
		echo "ECHO$char" >&p
	fi
	kill $f_pid &> /dev/null
	find . -type f -path "*`get_current_text`*" | process_results >&p &
	f_pid=$!
}
 
get_current_text() {
	local txt=
	echo "TXT" >&p
	read -u 4 txt
	echo -n "$txt"
}

run() {
	zmodload zsh/curses
	trap cleanup INT HUP TERM EXIT
	setup_screen
	export ipc_pipe=`mktemp -u`
	while ! mkfifo -m 600 "$ipc_pipe" &>/dev/null; do
		export ipc_pipe=`mktemp -u`
	done
	_shm_set "$wid:fuzzy-running" "${TMUX_PANE#*\%}"
	{ coproc renderer >&3 } 3>&1
	exec 4<"$ipc_pipe"
	getchar
	while true; do
		if [ $keycode != 27 ]; then
			process_char
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
