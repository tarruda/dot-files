tmux source $DOTDIR/tmux/tmuxrc
if [[ -r $DOTDIR/tmux/site-tmuxrc ]]; then
	tmux source $DOTDIR/tmux/site-tmuxrc
fi

# Vim/tmux integration {{{

# use alt+y/alt+p to seamless copy and paste between tmux, vim and the
# x11 clipboard if available
if which xclip &> /dev/null && [[ -n $DISPLAY ]]; then
	tmux bind -t vi-copy M-y copy-pipe 'xclip -i -selection clipboard'
	tmux bind -n M-p if\
	 	'cmd=$(tmux display -p "#{pane_current_command}"); [ $cmd = vim ] || [ $cmd = mutt ] || [ $cmd = psql ]'\
		"send-keys M-t 'mux' paste-tmux"\
		'run "xclip -o -selection clipboard | tmux load-buffer -; tmux paste-buffer"'
else
	tmux bind -t vi-copy M-y copy-selection
	tmux bind -n M-p if\
	 	'cmd=$(tmux display -p "#{pane_current_command}"); [ $cmd = vim ] || [ $cmd = mutt ] || [ $cmd = psql ]'\
		"send-keys M-t 'mux' paste-tmux"\
		"paste-buffer"
fi

# transparently move between tmux panes and vim splits using
# alt+[h|j|k|l] or alt+[left|down|up|right]
typeset -A vim_tmux_command_map
vim_tmux_command_map=(
	'M-j' 'move-down select-pane -D'
	'M-k' 'move-up select-pane -U'
	'M-h' 'move-left select-pane -L'
	'M-l' 'move-right select-pane -R'
	'M-Down' 'move-down select-pane -D'
	'M-Up' 'move-up select-pane -U'
	'M-Left' 'move-left select-pane -L'
	'M-Right' 'move-right select-pane -R'
)

for key in ${(k)vim_tmux_command_map}; do
	kv=${vim_tmux_command_map[$key]}
	vim_tmux_cmd=("${=kv}")
	tmux bind -n $key if\
		'[ $(tmux display -p "#{pane_current_command}") = vim ]'\
		"send-keys M-t 'mux' '$vim_tmux_cmd[1]'"\
		"$vim_tmux_cmd[2,-1]"
done
# }}}
