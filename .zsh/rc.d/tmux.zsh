if [ $TERM != "screen-256color" ] && [  $TERM != "screen" ]; then
	if which tmux &>/dev/null; then
		TERM=xterm-256color exec zsh -c 'tmux attach || tmux new'
	else
		alias vi='vim'
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

	# unregister from the shm server
	_shm_unregister() {
    local socket_path="/tmp/tmux-zsh-vim-shm/socket"
		if zsocket $socket_path > /dev/null 2>&1; then
      echo "EXIT|||$_shm_client_id" >&$REPLY
			exec {REPLY}>&-
		fi
	}

	# register to the shm server
	_shm_register() {
		local REPLY=
		local tmux_vim_socket_dir="/tmp/tmux-zsh-vim-shm"
    local socket_path="$tmux_vim_socket_dir/socket"
		# ensure the shared memory daemon is running:
		# - try to acquire the daemon lock, if succeeds:
		#	  - start a subshell
		#   - replace the subshell with a new, disowned shell
		#   - the new shell invokes start_shared_memory to finish
		#     the daemonization process and do the rest of the job
		if mkdir "$tmux_vim_socket_dir" > /dev/null 2>&1; then
			(
			exec zsh "$ZDOTDIR/tmux.d/shm_daemon.zsh" $tmux_vim_socket_dir &!
			)
		fi
		# now try to connect with the daemon, up to 5 times, increasing the poll
		# interval with each iteration
		local interval=
		for i in 1 2 3 4 5; do
			if zsocket $socket_path > /dev/null 2>&1; then
				break
			fi
			interval=$((i * 0.5))
			sleep $interval
		done
		if [ -z $REPLY ]; then
			echo "Error registering with the shared memory daemon" >&2
			local daemon_pid=
			if [ -r "$tmux_vim_socket_dir/pid" ]; then
				daemon_pid=`cat "$tmux_vim_socket_dir/pid"`
			fi
			if [ -z $daemon_pid ] || ! ps -p $daemon_pid; then
				local msg=
				msg=(
				"The process pointed by the daemon pid was"
				"not running, will delete the directory"
				"'$tmux_vim_socket_dir'"
				)
				echo "$msg" >&2
				rm -rf "$tmux_vim_socket_dir"
			fi
			return 1
		fi
		_shm_client_id=`uuidgen`
		echo "ENTER|||$_shm_client_id" >&$REPLY
		exec {REPLY}>&-
	}

	source "$ZDOTDIR/tmux.d/common.zsh"

  vi() {
		zsh "$ZDOTDIR/tmux.d/vi.zsh" "$@"
  }
	alias e=vi

	trap _shm_unregister EXIT
	_shm_register
fi
