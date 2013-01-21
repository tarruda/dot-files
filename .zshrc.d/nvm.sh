# Node.js version manager
# Adapted from https://raw.github.com/visionmedia/n/master/bin/n with some
# code taken from https://raw.github.com/creationix/nvm/master/nvm.sh
#
# Major differences:
# - It is not a binary to be installed on $PATH, but a function 
#		to be sourced by your shell init script
# - Doesn't require an existing node.js installation
# - Works out-of-box without root access(installs everything inside $HOME)
#
# Tested on zsh(but should work on most modern interactive shells)

if [ -z "$NVM_DIR" ]; then
	NVM_DIR="$HOME/.nvm"
fi

# setup

test -d "$NVM_DIR/versions" || mkdir -p "$NVM_DIR/versions"

# curl / wget support

NVM_GET=

# wget support (Added --no-check-certificate for Github downloads)
which wget > /dev/null && NVM_GET="wget --no-check-certificate -q -O-"

# curl support
which curl > /dev/null && NVM_GET="curl -# -L"

#
# nvm_log <type> <msg>
#

nvm_log() {
	printf "  \033[36m%10s\033[0m : \033[90m%s\033[0m\n" $1 $2
}

#
# Exit with the given <msg ...>
#

nvm_abort() {
	printf "\n  \033[31mError: $@\033[0m\n\n"
}

#
# Output usage information.
#

nvm_display_help() {
	cat <<- EOF

	Usage: nvm [options] [COMMAND]

	Commands:

	  nvm                            Select a node.js version
	  nvm latest                     Install or activate the latest node release
	  nvm stable                     Install or activate the latest stable node release
		nvm login										   Export the currently active version to the
																	 '.login' file. This can be used by '.profile'
																	 to set the PATH system-wide on login.
	  nvm install <version>          Installs node <version>
	  nvm activate <version>         Activates node <version>
	  nvm deactivate <version>       Activates node <version>
	  nvm bin <version>              Output bin path for <version>
	  nvm rm <version ...>           Remove the given version(s)
	  nvm prev                       Revert to the previously activated version
	  nvm ls                         Output the versions of node available

	Options:

	  -h, --help                     Display help information
	  --latest                       Output the latest node version available
	  --stable                       Output the latest stable node version available

	Aliases:

	  which   bin
	  use     as
	  list    ls
	  -       rm

	EOF
}


#
# Echoes the currently active version if any
#

nvm_get_current_version() {
	local active=""
	if [ -r "$NVM_DIR/.active" ]; then
		active=`cat "$NVM_DIR/.active"`
	fi
	echo "$active"
}

#
# Gets the version that corresponds to the selected index
#

nvm_get_version_for_index() {
	local i=0
	for dir in "$NVM_DIR/versions"/*; do
		local version="${dir##*/}"
		if [ "$i" = "$1" ]; then
			echo $version
			return
		fi
		i=$(($i + 1))
	done
	echo ""
}

#
# Display installed versions with <selected>.
#

nvm_display_versions_with_selected() {
	local selected=$1
	echo
	local i=0
	for dir in "$NVM_DIR/versions"/*; do
		local version="${dir##*/}"
		if test "$version" = "$selected"; then
			printf "  \033[36m$i)\033[0m $version\033[0m\n"
		else
			printf "  $i) \033[90m$version\033[0m\n"
		fi
		i=$(($i + 1))
	done
	echo
}


#
# Display current node --version
# and others installed.
#

nvm_display_versions() {
	local up=$'\033[A'
	local down=$'\033[B'
	local active=`nvm_get_current_version`
	local n=""
	local selected=""
	if [ -n "$active" ]; then
		nvm_display_versions_with_selected $active
		echo "Enter the number besides the version to activate it:"

		read n
		selected=`nvm_get_version_for_index $n`
		[ -z $selected ] && nvm_abort "Invalid selection" && return
		nvm_activate $selected
	else
		echo "No versions are installed yet. Enter 'nvm help' for usage info."
	fi
}

#
# Move up a line and erase.
#

nvm_erase_line() {
	printf "\033[1A\033[2K"
}

#
# Check if the HEAD response of <url> is 200.
#

nvm_is_ok() {
	curl -Is $1 | head -n 1 | grep 200 > /dev/null
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
# Activate <version>
#

nvm_activate() {
	nvm_deactivate > /dev/null
	local version=$1
	local dir="$NVM_DIR/versions/$version"
	local p="$NVM_DIR/versions/$version/bin"
	local mp="$NVM_DIR/versions/$version/share/man"
	if [ -d "$dir" ]; then
		if ! echo "$PATH" | grep -qF "$p:"; then
			export PATH="$p:$PATH"
		fi
		if ! echo "$MANPATH" | grep -qF "$mp:"; then
			export MANPATH="$p:$MANPATH"
		fi
		echo $version > "$NVM_DIR/.active"
		nvm_log activated `node --version`
		echo
	fi
}

#
# Deactivates the current version
#

nvm_deactivate() {
	local active=`nvm_get_current_version`
	if [ -n "$active" ]; then
		nvm_log deactivated $active
		echo $active > "$NVM_DIR/.prev"
		if echo "$PATH" | grep -qF "$NVM_DIR/versions/$active/bin:"; then
			export PATH="${PATH#$NVM_DIR/versions/$active/bin:}"
		fi
		if echo "$MANPATH" | grep -qF "$NVM_DIR/versions/$active/share/man:"; then
			export MANPATH="${MANPATH#$NVM_DIR/versions/$active/share/man:}"
		fi
		rm -f "$NVM_DIR/.active"
	fi
}

#
# Activate previous node.
#

nvm_activate_previous() {
	[ ! -r "$NVM_DIR/.prev" ] && nvm_abort "no previous versions activated" && return
	local prev=`cat "$NVM_DIR/.prev"`
	nvm_activate $prev
	echo
}

#
# Copies the currently active version to '.login'. This is useful if you need
# to set the $PATH on login instead of just when a interactive shell is opened.
# (eg setting environment for GUI apps)
#

nvm_login() {
	if [ -r "$NVM_DIR/.active" ]; then
		cp "$NVM_DIR/"{.active,.login}
	fi
}

#
# Install <version>
#

nvm_install() {
	local version=${1#v}
	local dir="$NVM_DIR/versions/$version"
	local url="`nvm_tarball_url $version`"
	local tarball="`nvm_tarball_name $version`"
	local downloads="$NVM_DIR/downloads"

	echo

	if [ -d "$dir" ]; then
		nvm_activate $version
	 	return
	fi

	nvm_log installing $version

	if ! nvm_is_ok $url; then
 		nvm_abort "invalid version $version" && return
	fi

	nvm_log "create dir" "$dir"
	mkdir -p "$dir"

	(
	# Run in a subshell so it won't affect the current shell cwd
	mkdir -p "$downloads";
	cd "$downloads";
	if [ ! -r "$tarball" ]; then
		nvm_log fetch $url
		eval "$NVM_GET $url" > "$tarball"
	fi
	cd "$dir";
	tar x --strip 1 -C "$dir" -f "$downloads/$tarball"
	# installs npm man pages
	# cd "share/man"
	# cp -as "$dir/lib/node_modules/npm/man/"* ./
	)
	nvm_erase_line

	nvm_activate $version
	nvm_log installed `node --version`
	echo
}

#
# Remove <version ...>
#

nvm_remove_version() {
	[ -z "$1" ] && nvm_abort "version(s) required" && return
	local version=${1#v}
	local active=`nvm_get_current_version`
	if [ "$version" = "$active" ]; then
		nvm_deactivate
	fi
	while test $# -ne 0; do
		rm -rf "$NVM_DIR/versions/$version"
		version=${1#v}
		shift
	done
}

#
# Output bin path for <version>
#

nvm_display_bin_path_for_version() {
	[ -z "$1" ] && nvm_abort "version required" && return
	local version=${1#v}
	local bin="$NVM_DIR/versions/$version/bin/node"
	if test -f "$bin"; then
		printf "$bin"
	else
		nvm_abort "$1 is not installed"
		return
	fi
}

#
# Execute the given <version> of node
# with [args ...]
#

nvm_execute_with_version() {
	[ -z "$1" ] && nvm_abort "version required" && return
	local version=${1#v}
	local bin="$NVM_DIR/versions/$version/bin/node"

	shift # remove version

	if [ -f "$bin" ]; then
		eval "$bin $@"
	else
		nvm_abort "$version is not installed"
		return
	fi
}

#
# Display the latest node release version.
#

nvm_display_latest_version() {
	eval "$NVM_GET http://nodejs.org/dist/" \
		| egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
		| sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
		| tail -n1
}

#
# Display the latest stable node release version.
#

nvm_display_latest_stable_version() {
	eval "$NVM_GET http://nodejs.org/dist/" \
		| egrep -o '[0-9]+\.\d*[02468]\.[0-9]+' \
		| sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
		| tail -n1
}

#
# Display the versions of node available.
#

nvm_display_remote_versions() {
	local active=`nvm_get_current_version`
	local versions=""
	versions=`eval "$NVM_GET 2> /dev/null http://nodejs.org/dist/" \
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
	test -z "$NVM_GET" && nvm_abort "curl or wget required" && return

	# Handle arguments
	if test $# -eq 0; then
		nvm_display_versions
	else
		case $1 in
			-h|--help|help) nvm_display_help ;;
			--latest) nvm_display_latest_version $2 ;;
			--stable) nvm_display_latest_stable_version $2 ;;
			bin|which) nvm_display_bin_path_for_version $2 ;;
			login) shift; nvm_login $@ ;;
			install) shift; nvm_install $@ ;;
			activate) shift; nvm_activate $@ ;;
			deactivate) nvm_deactivate ;;
			rm|-) nvm_remove_version $2 ;;
			latest) nvm_install `nvm --latest` ;;
			stable) nvm_install `nvm --stable` ;;
			ls|list) nvm_display_remote_versions $2 ;;
			prev) nvm_activate_previous ;;
			*) echo "Invalid command/option, type 'nvm help' for help" ;;
		esac
	fi
}

# Re-activates the last active version
[ -r "$NVM_DIR/.active" ] && nvm_activate `cat "$NVM_DIR/.active"` > /dev/null
