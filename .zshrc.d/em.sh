# curl / wget support

EM_GET=

# wget support (Added --no-check-certificate for Github downloads)
which wget > /dev/null && EM_GET="wget --no-check-certificate -q -O-"

# curl support
which curl > /dev/null && EM_GET="curl -# -L"


#
# em_info_log <type> <msg>
#

em_info_log() {
	printf "  \033[36m%10s\033[0m : \033[90m%s\033[0m\n" $1 $2
}


#
# em_error_log <msg ...>
#

em_error_log() {
	printf "\n  \033[31mError: $@\033[0m\n\n"
}


#
# Move up a line and erase.
#

em_erase_line() {
	printf "\033[1A\033[2K"
}


#
# Check if the HEAD response of <url> is 200.
#

em_url_ok() {
	curl -Is $1 | head -n 1 | grep 200 > /dev/null
}


#
# Echoes the currently active environment if any
#

em_get_current_environment() {
	local active=""
	if [ -r "$NVM_DIR/.active" ]; then
		active=`cat "$NVM_DIR/.active"`
	fi
	echo "$active"
}


#
# Gets the environment that corresponds to the selected index
#

em_get_environment_for_index() {
	local i=0
	for dir in "$NVM_DIR/environments"/*; do
		local environment="${dir##*/}"
		if [ "$i" = "$1" ]; then
			echo $environment
			return
		fi
		i=$(($i + 1))
	done
	echo ""
}


#
# Display installed environments with <selected>.
#

em_display_environments_with_selected() {
	local selected=$1
	echo
	local i=0
	for dir in "$NVM_DIR/environments"/*; do
		local environment="${dir##*/}"
		if [ "$environment" = "$selected" ]; then
			printf "  \033[36m$i)\033[0m $environment\033[0m\n"
		else
			printf "  $i) \033[90m$environment\033[0m\n"
		fi
		i=$(($i + 1))
	done
	echo
}


#
# Display current node environment
# and others installed.
#

em_display_environments() {
	local up=$'\033[A'
	local down=$'\033[B'
	local active=`em_get_current_environment`
	local n=""
	local selected=""
	if [ -n "$active" ]; then
		em_display_environments_with_selected $active
		echo "Enter the environment number to activate it:"

		read n
		selected=`em_get_environment_for_index $n`
		[ -z $selected ] && em_error_log "Invalid selection" && return
		nvm_activate $selected
	else
		echo "No versions are installed yet. Enter 'nvm help' for usage info."
	fi
}


##############################################################################

# Node.js environment/version manager
# Forked from https://raw.github.com/visionmedia/n/master/bin/n with some
# snippets taken from https://raw.github.com/creationix/nvm/master/nvm.sh

# Tested on zsh (but should work on most shells)

if [ -z "$NVM_DIR" ]; then
	NVM_DIR="$HOME/.nvm"
fi

#
# Output usage information.
#

nvm_display_help() {
	cat <<- EOF

	Usage: nvm [options] [COMMAND]

	Commands:

	  nvm                                  Select a node environment
	  nvm install <version>                Installs node <version>
	  nvm create <version> <environment>   Creates a node <environment> for
	                                       based on <version>
	  nvm activate <environment>           Activates node <environment>
	  nvm deactivate <environment>         Activates node <environment>
	  nvm bin <environment>                Output bin path for <environment>
	  nvm rm <environment ...>             Remove the given environment(s)
	  nvm ls                               Output the versions of node available
	  nvm prev                             Revert to the previously activated
	                                       environment
	  nvm login										         Export the currently active 
		                                     environment to the '.login' file. This
																				 can be used by '.profile' to set the
																				 PATH system-wide on login

	Options:

	  -h, --help                           Display help information
	  --latest                             Output the latest node version
	                                       available
	  --stable                             Output the latest stable node version
	                                       available

	Aliases:

	  which   bin
	  use     as
	  list    ls
	  -       rm

	Observations:

	  Whenever a version number is expected you can use 'latest' or 'stable'
		as aliases for the latest and latest stable version respectively. (A
		internet connection is required to resolve these aliases)

	EOF
}



#
# Determine tarball filename for <version>.
#

nvm_tarball_name() {
	local version=$1
	local uname="`uname -a`"
	local arch=x86
	local os=

	# from nave(1)
	case "$uname" in
		Linux*) os=linux ;;
		Darwin*) os=darwin ;;
		SunOS*) os=sunos ;;
	esac

	case "$uname" in
		*x86_64*) arch=x64 ;;
	esac
	echo "node-v${version}-${os}-${arch}.tar.gz"
}

#
# Determine tarball url for <version>.
#

nvm_tarball_url() {
	local version=$1
	echo "http://nodejs.org/dist/v${version}/`nvm_tarball_name $version`"
}

#
# Activate <environment>
#

nvm_activate() {
	nvm_deactivate > /dev/null
	local environment=$1
	local dir="$NVM_DIR/environments/$environment"
	local p="$NVM_DIR/environments/$environment/bin"
	local mp="$NVM_DIR/environments/$environment/share/man"
	if [ -d "$dir" ]; then
		if ! echo "$PATH" | grep -qF "$p:"; then
			export PATH="$p:$PATH"
		fi
		if ! echo "$MANPATH" | grep -qF "$mp:"; then
			export MANPATH="$p:$MANPATH"
		fi
		echo $environment > "$NVM_DIR/.active"
		em_info_log activated $environment
	fi
}

#
# Deactivates the current environment
#

nvm_deactivate() {
	local active=`em_get_current_environment`
	if [ -n "$active" ]; then
		em_info_log deactivated $active
		echo $active > "$NVM_DIR/.prev"
		if echo "$PATH" | grep -qF "$NVM_DIR/environments/$active/bin:"; then
			export PATH="${PATH#$NVM_DIR/environments/$active/bin:}"
		fi
		if echo "$MANPATH" | grep -qF "$NVM_DIR/environments/$active/share/man:"; then
			export MANPATH="${MANPATH#$NVM_DIR/environments/$active/share/man:}"
		fi
		rm -f "$NVM_DIR/.active"
		hash -r
	fi
}

#
# Activate previous environment
#

nvm_activate_previous() {
	[ ! -r "$NVM_DIR/.prev" ] && em_error_log "no previous environment was activated" && return
	local prev=`cat "$NVM_DIR/.prev"`
	nvm_activate $prev
	echo
}

#
# Copies the currently active environment to '.login'. This is useful if you need
# to set the $PATH on login instead of just when a interactive shell is opened.
# (eg setting environment for GUI apps)
#

nvm_login() {
	if [ -r "$NVM_DIR/.active" ]; then
		cp "$NVM_DIR/"{.active,.login}
	fi
}

#
# Resolve version name
#
nvm_normalize_version() {
	local version=${1#v}
	case $version in
		latest)
			version=`nvm_display_latest_version`
			;;
		stable)
			version=`nvm_display_latest_stable_version`
		 	;;
	esac
	echo "$version"
}


#
# Install <version>
#

nvm_install() {
	local version="`nvm_normalize_version $1`"
	local dir="$NVM_DIR/environments/$version"
	local url="`nvm_tarball_url $version`"
	local tarball="`nvm_tarball_name $version`"
	local downloads="$NVM_DIR/downloads"

	echo

	if [ -d "$dir" ]; then
		nvm_activate $version
		echo
	 	return
	fi

	em_info_log installing $version

	if ! em_url_ok $url; then
 		em_error_log "invalid version $version" && return
	fi

	em_info_log "create dir" "$dir"
	mkdir -p "$dir"

	(
	# Run in a subshell so it won't affect the current shell cwd
	mkdir -p "$downloads";
	cd "$downloads";
	if [ ! -r "$tarball" ]; then
		em_info_log fetch $url
		eval "$EM_GET $url" > "$tarball"
	fi
	cd "$dir";
	tar x --strip 1 -C "$dir" -f "$downloads/$tarball"
	)
	em_erase_line

	em_info_log installed $version
	nvm_activate $version
	echo
}

#
# Uninstall <version ...>
#
nvm_uninstall() {
	[ -z "$1" ] && em_error_log "version(s) required" && return
	local version=`nvm_normalize_version $1`
	while test $# -ne 0; do
		rm -rf "$NVM_DIR/versions/$versions"
		version=$1
		shift
	done
}

#
# Remove <environment ...>
#

nvm_remove() {
	[ -z "$1" ] && em_error_log "environment(s) required" && return
	local environment=$1
	local active=`em_get_current_environment`
	if [ "$environment" = "$active" ]; then
		nvm_deactivate
	fi
	while test $# -ne 0; do
		rm -rf "$NVM_DIR/environments/$environment"
		environment=$1
		shift
	done
}

#
# Output bin path for <environment>
#

nvm_display_bin_path_for_environment() {
	[ -z "$1" ] && em_error_log "environment required" && return
	local environment=$1
	local bin="$NVM_DIR/environments/$environment/bin/node"
	if test -f "$bin"; then
		printf "$bin"
	else
		em_error_log "$1 is not installed"
		return
	fi
}

#
# Display the latest node release version.
#

nvm_display_latest_version() {
	eval "$EM_GET http://nodejs.org/dist/" \
		| egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
		| sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
		| tail -n1
}

#
# Display the latest stable node release version.
#

nvm_display_latest_stable_version() {
	eval "$EM_GET http://nodejs.org/dist/" \
		| egrep -o '[0-9]+\.\d*[02468]\.[0-9]+' \
		| sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
		| tail -n1
}

#
# Display the versions of node available.
#

nvm_display_remote_versions() {
	local active=`em_get_current_environment`
	local versions=""
	versions=`eval "$EM_GET 2> /dev/null http://nodejs.org/dist/" \
		| egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
		| sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
		| awk 'BEGIN{print}{ print "  " $1 }'`

	echo
	for v in $versions; do
		if [ "$active" = "$v" ]; then
			printf "  \033[36mο\033[0m $v \033[0m\n"
		else
			if [ -d "$NVM_DIR/versions/$v" ]; then
				printf "    $v \033[0m\n"
			else
				printf "    \033[90m$v\033[0m\n"
			fi
		fi
	done
	echo
}


nvm() {
	# Ensure we have curl or wget
	test -z "$EM_GET" && em_error_log "curl or wget required" && return

	# Handle arguments
	if test $# -eq 0; then
		em_display_environments
	else
		case $1 in
			-h|--help|help) nvm_display_help ;;
			bin|which) nvm_display_bin_path_for_environment $2 ;;
			login) shift; nvm_login $@ ;;
			install) shift; nvm_install $@ ;;
			activate) shift; nvm_activate $@ ;;
			deactivate) nvm_deactivate ;;
			rm|-) nvm_remove $2 ;;
			ls|list) nvm_display_remote_versions $2 ;;
			prev) nvm_activate_previous ;;
			*) echo "Invalid command/option, type 'nvm help' for help" ;;
		esac
	fi
}

# Re-activates the last active version
[ -r "$NVM_DIR/.active" ] && nvm_activate `cat "$NVM_DIR/.active"` > /dev/null
