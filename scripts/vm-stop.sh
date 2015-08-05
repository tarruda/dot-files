if [ -e ~/.vbox-auto ]; then
for vm in $(echo $(cat ~/.vbox-auto | grep '^[^#]')); do
	VBoxManage controlvm ${vm} savestate
done
fi

if [ -e ~/.kvm-auto ]; then
for vm in $(echo $(cat ~/.kvm-auto | grep '^[^#]')); do
	if [ "x$(virsh domstate ${vm})" = "xrunning" ]; then
		mkdir -p ~/.kvm-state
		virsh save ${vm} ~/.kvm-state/${vm}
	fi
done
fi

if [ -e ~/.lxc-auto ]; then
expect << EOF
set timeout 300
spawn {*}{ssh lxcd}
send {
for container in $(echo $(cat ~/.lxc-auto | grep '^[^#]')); do
	lxc-stop -n \${container}
done
exit
}
expect eof
EOF
fi
