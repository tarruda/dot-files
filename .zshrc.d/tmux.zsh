if [ $TERM != "screen-256color" ] && [  $TERM != "screen" ]; then
  # Start tmux and call the trampoline on exit
  TERM=xterm-256color tmux new; jumper
else
  # tmux is running, define tmux-specific utilities
  tmw() {
    tmux split-window -dh "$*"
  }

  ssh() {
    echo "ssh $*;TERM=xterm-256color tmux a" > "$HOME/.jumper"
    tmux detach
  }

  # Sweet vim/tmux integration
  # Inspired by https://gist.github.com/2792055
  # TODO: Implement a fuzzy finder completion for zsh in the spirit of CtrlP vim plugin,
  #       then integrate with the function below

  vi() {
    # Get session/window ids
    # Lets see if we are in a project
    local dir=`pwd`
    local vim_id_pattern=""
    while [ -n "$dir" ] ; do
      [[ -d "$dir/.git" ||\
        -d "$dir/.svn" ||\
        -d "$dir/.hg" ] ||\
        -d "$dir/.bzr" ]] && break
      # go up one level
      dir=${dir%/*}
    done
    # since vim servername is case-insensitive, we need to get a tmux
    # session-specific surrogate uuid to use instead
    local sid=`tmux display-message -p '#S'`
    local socket_path="/tmp/tmux-zsh-vim-shm-$sid/listen"
    # connect to shared_memory
    zsocket $socket_path
    # ask for uuid for the directory
    echo "$dir" >&$REPLY
    # wait for response
    local dir_id=""
    read dir_id <&$REPLY
    # close the connection
    exec {REPLY}>&-
    vim_id_pattern=":${dir_id}:"
    local vim_id=`vim --serverlist | grep -F "$vim_id_pattern"`
    if [ -z $vim_id ]; then
      # vim is not running, so start a new instance 
      #
      # Before we can send commands to the new instance, it must be fully
      # started, so we need to syncronize the startup with this function using a
      # unique named pipe, which will also allow us to get the new pane id
      local fifo="/tmp/tmux-vim-pane-$RANDOM"
      while ! mkfifo $fifo > /dev/null 2>&1; do
        fifo="/tmp/tmux-vim-pane-$RANDOM"
      done
      # g:project_dir can be used by vim scripts that need to know the project
      # root directory
      tmux split-window -d -p 80 "vim \
        -c \"let g:project_dir='$dir'\" \
        -c vim -c ':silent !echo \$TMUX_PANE >> $fifo'\
        --servername \":$dir_id:\${TMUX_PANE#*\%}\""
      local pane_id=`cat $fifo`
      # will only get here after vim has started
      pane_id=${pane_id#*\%}
      vim_id=":$dir_id:$pane_id"
      rm $fifo
    fi
    # open all files
    vim --servername "$vim_id" --remote-send "<ESC>"
    while [ $# -ne 0 ]; do
      vim --servername "$vim_id" --remote-send ":e $1<CR>"
      shift
    done
    # extract the unique pane id from vim_id and navigate to it
    tmux select-pane -t "%${vim_id#\:$dir_id\:}"
  }

  # start the shared memory daemon:
  # - start a subshell
  # - set umask to 0 (by default anyone can read/write daemon-created files)
  # - try to acquire the daemon role atomically. If succeeds:
  #   - change dir to root
  #   - replace the subshell with a new, disowned shell,
  #     with sid set (ensures no controlling terminal)
  #   - the new shell invokes start_shared_memory to finish
  #     the daemonization process and do the rest of the job
  (
  umask 0
  tmux_sid=`tmux display-message -p '#S'`
  tmux_vim_socket_dir="/tmp/tmux-zsh-vim-shm-$tmux_sid"
  if mkdir "$tmux_vim_socket_dir" > /dev/null 2>&1; then
    cd /
    exec setsid zsh "$HOME/.zshrc.d/bin/shm_daemon.zsh" $tmux_vim_socket_dir $tmux_sid &!
  fi
  )
  # Start the daemon if it is not already started
  # TRAPEXIT() {
  #   local sid=`tmux display-message -p '#S'`
  #   local socket_path="/tmp/tmux-zsh-vim-shm-$sid/listen"
  #   if [ -S $socket_path ]; then
  #     zsocket $socket_path
  #     echo "EXIT" >&$REPLY
  #   fi
  # }
fi
