# Auto mount encrypted private directory
# This depends on the ecryptfs pam module to have
# already inserted the mount passphrase into the kernel
# keyring.
if [ -r "${HOME}/.ecryptfs/auto-mount" ]; then
    grep -qs "${HOME}/private ecryptfs" /proc/mounts
    if [ $? -ne 0 ]; then
        mount -i "${HOME}/private"
    fi
fi
