#!/usr/bin/env zsh

program="`tmux display -p '#{pane_current_command}'`"

# use xclip to get the clipboard contents, load into the tmux buffer and
# paste as terminal input into the current pane
xclip -o -selection clipboard | tmux load-buffer -
if [[ $program == "vim" ]]; then
	# if vim is focused, send the keys so it will handle the paste itself
	tmux send-keys 'M-p'
else
	tmux paste-buffer
fi
