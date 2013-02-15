#!/usr/bin/env zsh
source "$ZDOTDIR/tmux.d/common.zsh"

cleanup() {
	_shm_pop "$wid:fuzzy-open" > /dev/null
	_shm_pop "$wid:fuzzy-running" > /dev/null
	exit
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
		"zsh \"$ZDOTDIR/tmux.d/fuzzy_open.zsh\" $pid"
else
	trap cleanup HUP INT TERM EXIT
	pane_id="`_shm_get $wid:fuzzy-running`"
	if [ "%$pane_id" != "$TMUX_PANE" ]; then
		_shm_set "$wid:fuzzy-running" "${TMUX_PANE#*\%}"
		# zsh /home/tarruda/.zsh/tmux.d/fuzzy_find.zsh 'zsh /home/tarruda/.zsh/tmux.d/vi.zsh'
		zsh "$ZDOTDIR/tmux.d/fuzzy_find.zsh" "zsh '$ZDOTDIR/tmux.d/vi.zsh'"
		cleanup
	fi
fi
