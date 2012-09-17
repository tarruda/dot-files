function l {
        command ls --color=auto $@
}

alias ls=l
alias p='ps -e'

function la {
	l -lah $@
}

function mkdtmp {
        local name="/tmp/`cat /dev/urandom | tr -cd a-zA-Z0-9 | fold -w10 | head -n1`"
        while [ -d "$name" ]; do
            name="/tmp/`cat /dev/urandom | tr -cd a-zA-Z0-9 | fold -w10 | head -n1`"
        done
        mkdir "$name"
        echo "$name"
}

# Command-not-found(ubuntu/debian)
if [ -x "/usr/lib/command-not-found" ]; then
	function cnf_preexec() {
		typeset -g cnf_command="${1%% *}"
	}

	function cnf_precmd() {
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
