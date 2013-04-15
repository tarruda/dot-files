#rm -f $HOME/cygwin-session.log
#exec &> $HOME/cygwin-session.log

{ XWin -wgl -multiwindow -clipboard } &
xwin_pid=$!

export DISPLAY=:0.0

{ sleep 4 && xrdb $DOTDIR/.Xresources } &
{ sleep 4 && xhost 192.168.56.50 } &

if which pulseaudio &> /dev/null; then
	pulseaudio --start
fi

cd

nc -k -d -l 127.0.0.1 55555 | while read cmd; do
	(exec $cmd) &
done
