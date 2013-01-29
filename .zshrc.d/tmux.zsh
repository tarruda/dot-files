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

  vim_edit() {
    # Get session/window ids
    local sid=`tmux display-message -p '#S'`
    # Lets see if we are in a project
    local dir=`pwd`
    local server_id_pattern=""
    while [ -n "$dir" ] ; do
      [[ -d "$dir/.git" ||\
        -d "$dir/.svn" ||\
        -d "$dir/.hg" ] ||\
        -d "$dir/.bzr" ]] && break
      # go up one level
      dir=${dir%/*}
    done
    # Since vim only uses uppercase letters for server names, it makes sense
    # to convert manually now
    dir=${dir:u}
    # If no project directory was found, it means $dir is empty, but that is
    # fine as a name for the default vim instance
    server_id_pattern=":$dir:$sid:"
    local server_id=`vim --serverlist | grep -iF "$server_id_pattern"`
    if [ -z $server_id ]; then
      # vim is not running, so start a new instance 
      #
      # Before we can send commands to the new instance, it must be fully
      # started, so we need to syncronize the startup with this function using a
      # named pipe, which will also allow us to get the new pane id
      local fifo=/tmp/panefifo
      mkfifo $fifo
      # g:project_dir can be used by vim scripts that need to now the project
      # root directory
      tmux split-window -d -p 80 "vim \
        -c \"let g:project_dir='$dir'\" \
        -c vim -c ':silent !echo \$TMUX_PANE >> $fifo'\
        --servername \":$dir:$sid:\${TMUX_PANE#*\%}\""
      local pane_id=`cat $fifo`
      # will only get here after vim has started
      pane_id=${pane_id#*\%}
      server_id=":$dir:$sid:$pane_id"
      rm $fifo
    fi
    # open all files
    vim --servername "$server_id" --remote-send "<ESC>"
    while [ $# -ne 0 ]; do
      vim --servername "$server_id" --remote-send ":e $1<CR>"
      shift
    done
    # extract the unique pane id from the server name and navigate to it
    tmux select-pane -t "%${server_id##\:$dir\:$sid\:}"
  }

fi


