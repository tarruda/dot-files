#!/usr/bin/env zsh

program="`tmux display -p '#{pane_current_command}'`"

if [[ $program == "vim" ]]; then
	# let vim handle it
	tmux send-keys 'Escape' 'C-a' $1
else
	# do the normal tmux thing
	case $1 in
		j) tmux select-pane -D ;;
		k) tmux select-pane -U ;;
		h) tmux select-pane -L ;;
		l) tmux select-pane -R ;;
	esac
fi
