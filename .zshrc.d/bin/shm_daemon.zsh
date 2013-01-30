# This implements a simple daemon that listens on a unix socket
# (thanks to zsh awesomeness) whose purpose is to store key-value
# pairs globally. Only one instance of this should be running.
# each client process should register itself before making the
# first request and unregister on exit. When all clients are 
# unregistered, the daemon shouldo exit.

serve_request() {
  zsocket -a $1
  local conn=$REPLY
  local req=
  read req <&$conn
	local parsed_req=
	parsed_req=(${(s:|||:)req})
	case $parsed_req[1] in
		ENTER)
			# the client is registering itself
			clients[$parsed_req[2]]=1
			echo "Client $parsed_req[2] registered"
			;;
		EXIT)
			# the client is unregistering itself
			unset "clients[$parsed_req[2]]"
			echo "Client $parsed_req[2] unregistered"
			if [ ${#clients} -eq 0 ]; then
				echo "No more clients are remaining, exiting daemon"
				exec {conn}>&-
				rm -rf "$socket_dir"
				exit
			fi
			;;
		GET)
			echo -n "GET $parsed_req[2];"
			# get a value
			if [ ! -z $data[$parsed_req[2]] ]; then
				echo "found: $data[$parsed_req[2]]"
				echo $data[$parsed_req[2]] >&$conn
			elif [ ! -z $parsed_req[3] ]; then
				echo "not found, but setting it to: $parsed_req[3]"
				# a default value was provided, set and return it
				data[$parsed_req[2]]=$parsed_req[3]
				echo $parsed_req[3] >&$conn
			else
				echo "not found"
			fi
			;;
	esac
	# force connection close
  exec {conn}>&-
}

# to finish the daemonization process, we ensure stdio fds are closed
# (they should already by closed by setsid) and perform a second fork
zmodload zsh/net/socket
socket_dir=$1
[[ -t 0 ]] && exec <&-
[[ -t 1 ]] && exec >&-
[[ -t 2 ]] && exec 2>&-
(
logfile=/tmp/tmux-zsh-vim-shm.log
exec > /dev/null
exec 2>> $logfile
# actual data being managed
typeset -A data
data=()
# registered client processes. used mainly to know when the daemon should exit
typeset -A clients
clients=()
zsocket -l "$socket_dir/socket" || exit 1
echo $$ > "$socket_dir/pid"
sock_fd=$REPLY
echo "Shared memory daemon listening on '$socket_dir/socket'"
while true; do
	serve_request $sock_fd
done
) &!
