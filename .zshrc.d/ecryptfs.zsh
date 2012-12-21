decrypt() {
	local p="$HOME/.ecryptfs/mounts.txt"
	if [ -r "$p" ]; then
		ecryptfs-add-passphrase
		for dir in `cat "$p"`; do
			mount -i "$dir"
		done
	fi
}

set-encrypted-dir() {
	lower="$1"
	upper="$2"
	if [ -z "$lower" ] || [ -z "$upper" ]; then
		echo "Specify lower and upper directories"
		return
	fi
	for d in "$upper" "$lower"; do 
		if [ -e "$d" ]; then
			if [ -d "$d" ]; then
				echo "'$d' already exists, will try to remove it"
				if ! rmdir "$d"; then
					echo "Directory '$d' is not empty"
				 	return
				fi
			else
				echo "'$d' is not a directory"
				return
			fi
		fi
	done
	cwd=`pwd`
	upper="$cwd/$upper"
	lower="$cwd/$lower"
	upper=`normalize_path $upper`
	lower=`normalize_path $lower`
	echo "Enter the encryption passphrase:"
	read -s  passphrase
	mkdir -m 700 "$lower"
	mkdir -m 500 "$upper"
	sudo echo "preparing for first mount..."
	sudo mount -t ecryptfs "$lower" "$upper" <<- EOF
	$passphrase
	aes
	32
	n
	y

	yes
	yes
	EOF
	cat /etc/mtab | grep "$upper"
}
