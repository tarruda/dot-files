if [ -z "$EM_DIR" ]; then
	EM_DIR="$HOME/.env-manager"
fi

for prog in node; do
	if [ -r "$EM_DIR/$prog/.login" ]; then
		environment=`cat "$EM_DIR/$prog/.login"`
		d="$EM_DIR/$prog/environments/$environment/bin"
		if [ -d "$d" ]; then
			export PATH="$d:$PATH"
		fi
	fi
done
