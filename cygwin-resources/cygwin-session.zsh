rm -f $HOME/cygwin-session.log
exec &> $HOME/cygwin-session.log

{ XWin -wgl -multiwindow -clipboard } &

export DISPLAY=:0.0

{ sleep 2 && xrdb $DOTDIR/.Xresources } &
{ sleep 2 && xhost 192.168.56.50 } &

if which pulseaudio &> /dev/null; then
	pulseaudio --start
fi

cd

nc -k -d -l 127.0.0.1 55555 | while read cmd; do
	{ eval $cmd } &!
done

