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
