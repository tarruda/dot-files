if [[ -z $NOTMUX && -z $TMUX ]]; then
	if which tmux &>/dev/null; then
		exec zsh -c 'tmux attach || tmux new'
	else
		[[ -n $NOTMUX ]] && unset NOTMUX
		alias vi=vim
	fi
else

	if [[ -r "$HOME/.tmux-local.conf" ]]; then
		tmux source-file "$HOME/.tmux-local.conf"
	fi

  # tmux is running, define tmux-specific utilities

  vi() {
		zsh "$ZDOTDIR/tmux.d/vim-tmux-open.zsh" "$@"
  }
fi

alias e=vi
