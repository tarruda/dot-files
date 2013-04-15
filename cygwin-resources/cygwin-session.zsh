exec &> $HOME/.cygwin-session.log

# For now VcXsrv seems to be the best windows x server
cd /cygdrive/d/vcxsrv
vcxsrv.exe -wgl -multiwindow -clipboard -ac &

export DISPLAY=:0.0
export SHELL=/bin/zsh
unset SHLVL
cd

sleep 4 && xrdb $DOTDIR/.Xresources &

if which pulseaudio &> /dev/null; then
	pulseaudio --start
fi

urxvtd -q -o -f

nc -k -d -l 127.0.0.1 55555 | while read cmd; do
	# split/expand the arguments
	cmdline=()
	for arg in ${(z)cmd}; do
		cmdline+=${~${(Q)arg}}
	done
	(exec ${cmdline}) &
	echo "exec ${cmdline}"
done
