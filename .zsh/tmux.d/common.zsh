zmodload zsh/net/socket
# gets value mapped to the key from the shared memory daemon. optionally, it
# can receive a third argument which is a value to be set(atomically) for
# the key, in case it is not yet present in the dictionary.
_shm_get() {
	local socket_path="/tmp/tmux-zsh-vim-shm/socket"
	local key=$1
	local default=$2
	# message to be sent to the daemon
	local req=""
	if [ -z $default ]; then
		req="GET|||${key}"
	else
		req="GET|||${key}|||${default}"
	fi
	# variable used by zsh that will point to the connection fd
	local REPLY=""
	# connect to the daemon
	if ! zsocket $socket_path; then
		echo "Failed connecting to $socket_path"
		return 1
	fi
	# send the message
	echo "$req" >&$REPLY
	# read response
	local res=""
	read res <&$REPLY
	# close the connection
	exec {REPLY}>&-
	[ ! -z $res ] && echo "$res"
}

# sets key on shared memory daemon.
_shm_set() {
	local socket_path="/tmp/tmux-zsh-vim-shm/socket"
	local key=$1
	local value=$2
	local req=""
	req="SET|||${key}|||${value}"
	local REPLY=""
	if ! zsocket $socket_path; then
		echo "Failed connecting to $socket_path"
		return 1
	fi
	echo "$req" >&$REPLY
	# no need for response
	exec {REPLY}>&-
}

# pops key from shared memory daemon.
_shm_pop() {
	local socket_path="/tmp/tmux-zsh-vim-shm/socket"
	local key=$1
	local value=$2
	local req=""
	req="POP|||${key}"
	local REPLY=""
	if ! zsocket $socket_path; then
		echo "Failed connecting to $socket_path"
		return 1
	fi
	echo "$req" >&$REPLY
	local res=""
	read res <&$REPLY
	exec {REPLY}>&-
	[ ! -z $res ] && echo "$res"
}
