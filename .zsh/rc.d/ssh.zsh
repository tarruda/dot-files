ssh() {
	{ ssh-add -l &> /dev/null || ssh-add } && { TERM=xterm-256color command ssh "$@" }
}
