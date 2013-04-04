tmux source $DOTDIR/tmux/tmuxrc
if [[ -r $DOTDIR/tmux/site-tmuxrc ]]; then
	tmux source $DOTDIR/tmux/site-tmuxrc
fi
