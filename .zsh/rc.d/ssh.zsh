ssh() {
	{ ssh-add -l &> /dev/null || ssh-add } && { command ssh "$@" }
}
