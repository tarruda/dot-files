exec &> $HOME/.cygwin-session.log
exec < /dev/null

# Setup some basic environment
export SHELL=/bin/zsh
unset SHLVL

# go to home directory
cd

xrdb $DOTDIR/.Xresources

urxvtd -q -o -f

# play audio from the VM
if which pulseaudio &> /dev/null; then
	pulseaudio --start
fi

# listen on port 55555 for commands to run in this session
nc -k -d -l 127.0.0.1 55555 | while read cmd; do
	# split/expand the arguments
	cmdline=()
	for arg in ${(z)cmd}; do
		cmdline+=${~${(Q)arg}}
	done
	(exec ${cmdline}) &
	echo "exec ${cmdline}"
done