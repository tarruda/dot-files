if [[ -z $TMUX ]]; then
	if which tmux &>/dev/null && tmux has -t auto-attach &> /dev/null; then
		exec tmux a -t auto-attach
	else
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
