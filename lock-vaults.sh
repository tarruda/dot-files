#!/bin/bash -e

if [ ! -r ~/.vaults ]; then
	echo "no vaults" 2>&1
	exit
fi

while read file dm mp; do
	dev=/dev/$(sudo dmsetup deps -o devname ${dm} | sed -e 's/^.*(\([^)]\+\)).*$/\1/g')
	sudo umount ${mp}
	sudo cryptsetup close ${dm}
	sudo losetup -d ${dev}
done < ~/.vaults
