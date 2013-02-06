#!/bin/sh

# For some strange reason, in FreeBSD some of the commands here only
# work when output is redirected, if openbox is started using slim
exec > /dev/null
exec 2>&1

if which VBoxClient > /dev/null 2>&1; then
	# If running as virtualbox guest, initialize guest additions features
	VBoxClient --clipboard
	VBoxClient --display
	VBoxClient --seamless
fi

tint2 &
