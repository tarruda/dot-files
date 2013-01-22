if [ -z "$NVM_DIR" ]; then
	NVM_DIR="$HOME/.nvm"
fi

if [ -r "$NVM_DIR/.login" ]; then
	# Set the PATH for the exported node.js environment
	environment=`cat "$NVM_DIR/.login"`
	d="$NVM_DIR/environments/$environment/bin"
	if [ -d "$d" ]; then
		export PATH="$d:$PATH"
	fi
fi
