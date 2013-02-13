# Mount many encfs volumes using a single key
decrypt() {
	local p="$HOME/.encfs/mounts.txt"
	if [ -r "$p" ]; then
		echo "Enter the encryption key:"
		read -s key
		exec 3<"$p"
		local line=
		while read -u 3 line; do
			line=(${(s: :)line})
			if [ ${#line} -ne 2 ]; then
				echo "invalid line '$line'" >&2
				return 1
			fi
			local src=${~line[1]} 
			if [ ! -r "${src}/.encfs6.xml" ]; then
				echo "invalid source '$src'"
				return 1
			fi
			local tgt=${~line[2]}
			if [ ! -d "${tgt}" ]; then
				echo "invalid target '$tgt'"
				return 1
			fi
			echo "$key" | encfs -S "$src" "$tgt"
			if [ $? -eq 0 ]; then
				echo "mounted $src on $tgt"
			else
				return 1
			fi
		done
		exec 3>&-
		echo "done"
	fi
}
