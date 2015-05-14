#!/bin/bash -e

if [ ! -r ~/.vaults ]; then
	echo "no vaults" 2>&1
	exit
fi

loop_release() {
	sudo cryptsetup close ${dm}
	sudo losetup -d ${dev}
}

trap loop_release ERR

echo -n "Passphrase: "
read -s pw
echo

while read file dm mp; do
	dev=$(sudo losetup -f)
	sudo losetup ${dev} ${file}
	echo ${pw} | sudo cryptsetup open --type plain ${dev} ${dm}
	sudo mount /dev/mapper/${dm} ${mp}
done < ~/.vaults
