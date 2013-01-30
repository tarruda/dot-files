if [ ! -e "$HOME/.ssh" ]; then
	mkdir -m 700 "$HOME/.ssh"
fi 

if [ ! -e "$HOME/.ssh/config" ]; then
	cat > "$HOME/.ssh/config" <<- EOF
	ServerAliveInterval 60
	ServerAliveCountMax 2
	EOF
fi
