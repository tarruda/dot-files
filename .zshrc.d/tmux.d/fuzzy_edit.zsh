#!/usr/bin/env zsh
# Simple fuzzy file opener
getchar() {
	read -r -k 1 c
	c_val=`printf "%d" "'$c'"`
}

erase_line() {
	printf "\033[1A\033[2K"
}

cleanup() {
	_shm_pop "$wid:fuzzy-open" > /dev/null
	_shm_pop "$wid:fuzzy-running" > /dev/null
}

split() {
	_shm_set "$wid:fuzzy-open" 1
	tmux split-window -t $wid -l 10\
		"zsh \"$HOME/.zshrc.d/tmux.d/fuzzy_edit.zsh\" $pid"
}

fuzzy_run() {
	trap cleanup INT HUP TERM EXIT
	_shm_set "$wid:fuzzy-running" "${TMUX_PANE#*\%}"
	getchar
	while true; do
		if [ $c_val != 27 ]; then
			echo "pressed $c"
		else
			break
		fi
		getchar
		erase_line
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
		fuzzy_run
	fi
fi
