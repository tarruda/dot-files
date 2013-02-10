#!/usr/bin/env zsh
source "$HOME/.zshrc.d/tmux.d/common.zsh"

cleanup() {
	_shm_pop "$wid:fuzzy-open" > /dev/null
	_shm_pop "$wid:fuzzy-running" > /dev/null
}

pid=$1
wid="`tmux display-message -pt \"$pid\" '#{window_id}'`" 2>/dev/null
if [ -z $wid ]; then
	echo "Cannot find window"
	exit
fi
is_open="`_shm_get $wid:fuzzy-open`"
if [ -z $is_open ]; then
	_shm_set "$wid:fuzzy-open" 1
	tmux split-window -t $wid -l 10\
		"zsh \"$HOME/.zshrc.d/tmux.d/fuzzy_open.zsh\" $pid"
else
	trap cleanup EXIT
	pane_id="`_shm_get $wid:fuzzy-running`"
	if [ "%$pane_id" != "$TMUX_PANE" ]; then
		_shm_set "$wid:fuzzy-running" "${TMUX_PANE#*\%}"
		zsh "$HOME/.zshrc.d/tmux.d/fuzzy_edit.zsh"
		cleanup
	fi
fi
