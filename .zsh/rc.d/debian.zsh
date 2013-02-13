# Command-not-found(ubuntu/debian)
if [ -x "/usr/lib/command-not-found" ]; then
	cnf_preexec() {
		typeset -g cnf_command="${1%% *}"
	}

	cnf_precmd() {
		(($? == 127)) && [ -n "$cnf_command" ] && [ -x /usr/lib/command-not-found ] && {
			whence -- "$cnf_command" >& /dev/null ||
				/usr/bin/python /usr/lib/command-not-found -- "$cnf_command"
			unset cnf_command
		}
	}
	typeset -ga preexec_functions
	typeset -ga precmd_functions
	preexec_functions+=cnf_preexec
	precmd_functions+=cnf_precmd
fi
