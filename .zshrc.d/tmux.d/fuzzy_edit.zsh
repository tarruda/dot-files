#!/usr/bin/env zsh
# Simple fuzzy file opener

cleanup() {
	zcurses end
	_shm_pop "$wid:fuzzy-open" > /dev/null
	_shm_pop "$wid:fuzzy-running" > /dev/null
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
	zcurses addwin input_box 1 $COLUMNS 10 0
	zcurses string header "Fuzzy file search"
	zcurses refresh header results input_box
}

getchar() {
	zcurses input input_box char
	if [ -n $char ]; then
		zcurses char header $char
		zcurses move results 0 0
	fi
	keycode=`printf "%d" "'$char'"`
}

fuzzy_find() {
	find . -type f
	
}

process_char() {
	zcurses string results "Pressed $char"
	zcurses refresh results input_box
	# coproc fuzzy_find
	# local f_pid=$!
}
 
run() {
	zmodload zsh/curses
	trap cleanup INT HUP TERM EXIT
	setup_screen
	_shm_set "$wid:fuzzy-running" "${TMUX_PANE#*\%}"
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
