#!/usr/bin/env zsh

if (( $# < 1 )); then
	echo "Need at least one argument" >&2
	exit 1
fi
program="`tmux display -p '#{pane_current_command}'`"
vim_cmd=$1
tmux_cmd=$2

if [[ $program == "vim" ]]; then
	# let vim handle it
	tmux send-keys 'M-t' 'mux' ${(z)vim_cmd}
elif [[ -n $tmux_cmd ]]; then
	tmux ${(z)tmux_cmd}
fi
