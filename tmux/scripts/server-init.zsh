tmux source $DOTDIR/tmux/tmuxrc
if [[ -r $DOTDIR/tmux/site-tmuxrc ]]; then
	tmux source $DOTDIR/tmux/site-tmuxrc
fi

# vim integration 

# use alt+y/alt+p to seamless copy and paste between tmux, vim and the
# x11 clipboard if available
if which xclip &> /dev/null && [[ -n $DISPLAY ]]; then
	tmux bind -t vi-copy M-y copy-pipe 'xclip -i -selection clipboard'
else
	tmux bind -t vi-copy M-y copy-selection
fi

typeset -A vim_tmux_command_map
vim_tmux_command_map=(
	'M-p' 'paste-tmux paste-buffer'
	'M-j' 'move-down "select-pane -D"'
	'M-k' 'move-up "select-pane -U"'
	'M-h' 'move-left "select-pane -L"'
	'M-l' 'move-right "select-pane -R"'
	'M-Down' 'move-down "select-pane -D"'
	'M-Up' 'move-up "select-pane -U"'
	'M-Left' 'move-left "select-pane -L"'
	'M-Right' 'move-right "select-pane -R"'
)

for key in ${(k)vim_tmux_command_map}; do
	tmux bind -n $key run "zsh $DOTDIR/tmux/scripts/vim-tmux-command.zsh ${vim_tmux_command_map[$key]}"
done
