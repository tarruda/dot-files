if [ ! -e "$HOME/.ssh" ]; then
	mkdir -m 700 "$HOME/.ssh"
fi 

if [ ! -e "$HOME/.ssh/config" ]; then
	cat > "$HOME/.ssh/config" <<- EOF
	ServerAliveInterval 60
	ServerAliveCountMax 2
	EOF
fi

# Ensure ssh agent is running
SSHPID=`ps ax | grep -c "[s]sh-agent"`
if [ $SSHPID -eq 0 ]; then
	ssh-agent > "$HOME/.ssh-env"
fi
. "$HOME/.ssh-env"
