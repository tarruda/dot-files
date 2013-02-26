if [[ $TERM != "tmux" && $TERM != "screen-256color" && $TERM != "screen" ]]; then
	if which tmux &>/dev/null; then
		if [[ -z $SHELR ]]; then
			exec zsh -c 'tmux attach || tmux new'
		elif [[ $SHELR == '1' ]]; then
			SHELR='2' shelr record
		fi
	else
		alias vi=vim
	fi
else
  # tmux is running, define tmux-specific utilities
  tmw() {
    tmux split-window -dh "$*"
  }

  ssh() {
		# TODO match the host against a list of hosts known to be running tmux
		tmux set status off
		tmux set prefix ^o
		ssh-add -l || ssh-add && { command ssh "$@" }
		tmux set -u prefix
		tmux set -u status
  }

  vi() {
		zsh "$ZDOTDIR/tmux.d/vi.zsh" "$@"
  }

	alias e=vi
fi
