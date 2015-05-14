if [ -e ~/.lxc-auto ]; then
expect << EOF
set timeout 300
spawn {*}{ssh lxcd}
send {
for container in $(echo $(cat ~/.lxc-auto)); do
	lxc-start -n \${container} -d
done
exit
}
expect eof
EOF
fi

if [ -e ~/.kvm-auto ]; then
for vm in $(echo $(cat ~/.kvm-auto)); do
	if [ -e ~/.kvm-state/${vm} ]; then
		virsh restore ~/.kvm-state/${vm}
		rm -f ~/.kvm-state/${vm}
	elif [ "x$(virsh domstate ${vm})" = "xshut off" ]; then
		virsh start ${vm}
	fi
done
fi

if [ -e ~/.vbox-auto ]; then
for vm in $(echo $(cat ~/.vbox-auto)); do
	VBoxManage startvm ${vm} --type headless
done
fi
