# This implements a simple daemon that listens on a unix socket
# (thanks to zsh awesomeness) whose purpose is to store key-value
# pairs specific to the tmux session. Only one instance should be running for
# each tmux session, and it should also exit when the last window exits
# 
# So far, the only reason to implement this is because vim servername is
# case-insensitive, so we cant have a 1-1 mapping between servers and
# directories. This daemon will store a table for mapping directory->uuid that
# will be used as servernames
# - close stdio fds
# - fork again and make the child start working
zmodload zsh/net/socket
socket_dir=$1
sid=$2
[[ -t 0 ]] && exec </dev/null
[[ -t 1 ]] && exec >/dev/null
[[ -t 2 ]] && exec 2>/dev/null
(
exec > /tmp/tmux-zsh-vim-shm-${sid}.log
exec 2> /tmp/tmux-zsh-vim-shm-${sid}.log
typeset -A data
data=()
zsocket -l "$socket_dir/listen" || exit 1
sock_fd=$REPLY
while true; do
  zsocket -a $sock_fd
  # We will be passed a directory name as key, and if it does not currently
  # have a corresponding value we create and store it. 
  # Finally we return the unique value which represents the directory
  local conn=$REPLY
  dir=""
  read dir <&$conn
  # close input fd
  # exec $REPLY<&-
  # close output fd
  # exec $REPLY>&-
  if [ "$dir" = "EXIT" ]; then
    # A shell is exiting, wait a little bit and check if the session
    # still exists
    sleep 0.5
    if ! tmux has-session -t $sid > /dev/null 2>&1; then
      break
    fi
  fi
  if [ -z $data[$dir] ]; then
    data[$dir]=`uuidgen -t`
    # to normalize with vim server naming, convert the uuid to uppercase
    data[$dir]=${data[$dir]:u}
  fi
  # send uuid
  echo $data[$dir] >&$conn
  echo "`ls /proc/self/fd`"
  exec {conn}>&-
done
) &!
