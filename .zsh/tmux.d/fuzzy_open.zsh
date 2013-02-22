#!/usr/bin/env zsh

cleanup() {
	tmux set -uq "@$wid:fuzzy-open" 
	tmux set -uq "@$wid:fuzzy-running" 
	exit
}

wid=${${(z)$(tmux list-windows | grep active)}[-4]}
if [ -z $wid ]; then
	echo "Cannot find window"
	exit
fi
pid=${${(z)$(tmux list-panes -t $wid | grep active)}[-4]}
is_open="`tmux show -v \"@$wid:fuzzy-open\" 2>/dev/null `"
if [ -z $is_open ]; then
	tmux set -q "@$wid:fuzzy-open" 1
	tmux split-window -t $wid -l 10\
		"zsh \"$ZDOTDIR/tmux.d/fuzzy_open.zsh\" $pid"
else
	trap cleanup HUP INT TERM EXIT
	pane_id="`tmux show -v \"@$wid:fuzzy-running\" 2>/dev/null`"
	if [ "%$pane_id" != "$TMUX_PANE" ]; then
		tmux set -q "@$wid:fuzzy-running" "${TMUX_PANE#*\%}"
		{ sleep 0.1 && tmux send-keys -t $TMUX_PANE 'C-x' 'C-x' } &
		zsh
		cleanup
	fi
fi
