if [ $TERM != "screen-256color" ] && [  $TERM != "screen" ]; then
  TERM=xterm-256color tmux new; jumper
else

  tmw() {
    tmux split-window -dh "$*"
  }

  ssh() {
    echo "ssh $*;TERM=xterm-256color tmux a" > "$HOME/.jumper"
    tmux detach
  }
fi



