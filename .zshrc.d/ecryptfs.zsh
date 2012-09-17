decrypt() {
	local p="$HOME/.ecryptfs/mounts.txt"
	if [ -r "$p" ]; then
		ecryptfs-add-passphrase
		for dir in `cat "$p"`; do
			mount -i "$dir"
		done
	fi
}
