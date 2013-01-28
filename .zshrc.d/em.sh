##############################################################################

# Node.js environment/version manager
# Forked from https://raw.github.com/visionmedia/n/master/bin/n with some
# snippets taken from https://raw.github.com/creationix/nvm/master/nvm.sh

# Tested on zsh (but should work on most shells)

if [ -z "$EM_DIR" ]; then
	EM_DIR="$HOME/.env-manager"
fi

# curl / wget support

EM_GET=

# wget support (Added --no-check-certificate for Github downloads)
which wget > /dev/null && EM_GET="wget --no-check-certificate -q -O-"

# curl support
which curl > /dev/null && EM_GET="curl -# -L"


#
# Output usage information.
#

em_display_help() {
	cat <<- EOF

	Usage: em [options] [PROGRAM] [COMMAND]

	Programs:

	  node                                 Node.js (server-side javascript)


	Commands:

	  compile <version> [alias] [config]   Compiles and installs [PROGRAM]
	 	                                     <version> as <alias> with aditional
																				 configuration [config]
	  install <version> [alias]            Installs [PROGRAM] <version> as
	 	                                     <alias>
	  uninstall <version>                  Uninstall [PROGRAM] <version>
	  add <version> <environment>          Adds a new <environment> for
	                                       [PROGRAM] based on <version>
	  rm <environment ...>                 Remove the given [PROGRAM] environment(s)
	  activate <environment>               Activates [PROGRAM] <environment>
	  deactivate <environment>             Activates [PROGRAM] <environment>
	  bin <environment>                    Output bin path for <environment>
	  ls                                   Output the versions of [PROGRAM] available
	  prev                                 Revert to the previously activated
	                                       environment
	  login                                Export the currently active
	                                       environment to the '.login' file. This
	                                       can be used by '.profile' to set the
	                                       PATH system-wide on login

	Options:

	  -h, --help, help                     Display this message

	Aliases:

	  which         bin
	  use, as       activate
	  list          ls
	  -             rm

	Tips:
	
	  - You can use the aliases 'lastest' or 'stable' when installing a version

	EOF
}


#
# Escapes a string for use as a sed search pattern
#
em_escape_for_sed() {
	echo "$1" | sed -e 's/[]\/()$*.^|[]/\\&/g'
}

#
# em_info_log <type> <msg>
#

em_info_log() {
	printf "  \033[36m%15s\033[0m : \033[90m%s\033[0m\n" $1 $2
}


#
# em_warn_log <type> <msg>
#

em_warn_log() {
	printf "  \033[33m%15s\033[0m : \033[90m%s\033[0m\n" $1 $2
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
	local prog=$1
	local active=""
	local envs="`ls \"$EM_DIR/$prog/environments\" 2> /dev/null`"
	if [ -r "$EM_DIR/$prog/.active" ]; then
		active=`cat "$EM_DIR/$prog/.active"`
	elif [ -n $envs ]; then
		active="none"
	fi
	echo "$active"
}


#
# Gets the environment that corresponds to the selected index
#

em_get_environment_for_index() {
	local prog=$1
	local i=0
	for dir in "$EM_DIR/$prog/environments"/*; do
		local environment="${dir##*/}"
		if [ "$i" = "$2" ]; then
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
	local prog=$1
	local selected=$2
	echo
	local i=0
	for dir in "$EM_DIR/$prog/environments"/*; do
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
# Display current environment and others installed.
#

em_display_environments() {
	local prog=$1
	local up=$'\033[A'
	local down=$'\033[B'
	local active=`em_get_current_environment $prog`
	local n=""
	local selected=""
	if [ -n "$active" ]; then
		em_display_environments_with_selected $prog $active
		echo -n "Enter the environment number to activate it: "

		read n
		echo
		selected=`em_get_environment_for_index $prog $n`
		[ -z $selected ] && em_error_log "Invalid selection" && return
		em_activate $prog $selected
		echo
	else
		echo "No versions are installed yet. Try 'em $prog install stable'."
	fi
}



#
# Activate <environment>
#

em_activate() {
	local $prog=$1
	em_deactivate $prog > /dev/null
	local environment=$2
	local dir="$EM_DIR/$prog/environments/$environment"
	local p="$dir/bin"
	local mp="$dir/share/man"
	if [ -d "$dir" ]; then
		if ! echo "$PATH" | grep -qF "$p:"; then
			export PATH="$p:$PATH"
		fi
		if ! echo "$MANPATH" | grep -qF "$mp:"; then
			export MANPATH="$p:$MANPATH"
		fi
		case $prog in
			node) export NODE_PATH="$dir/lib/node_modules" ;;
		esac
		echo $environment > "$EM_DIR/$prog/.active"
		em_info_log activated "$prog $environment"
	fi
}

#
# Deactivates the current environment
#

em_deactivate() {
	local prog=$1
	local active=`em_get_current_environment $prog`
	if [ -n "$active" ]; then
		local dir="$EM_DIR/$prog/environments/$active"
		local p="$dir/bin"
		local mp="$dir/share/man"
		echo $active > "$EM_DIR/$prog/.prev"
		if echo "$PATH" | grep -qF "$p:"; then
			export PATH="${PATH#$p:}"
		fi
		if echo "$MANPATH" | grep -qF "$mp:"; then
			export MANPATH="${MANPATH#$mp:}"
		fi
		case $prog in
			node) unset NODE_PATH ;;
		esac
		rm -f "$EM_DIR/$prog/.active"
		hash -r
		em_info_log deactivated "$prog $active"
	fi
}

#
# Activate previous environment
#

em_activate_previous() {
	local prog=$1
	if [ ! -r "$EM_DIR/$prog/.prev" ]; then
	 	em_error_log "no previous environment for $prog was activated" && return
	fi
	local prev=`cat "$EM_DIR/$prog/.prev"`
	em_activate $prog $prev
	echo
}

#
# Copies the currently active environment to '.login'. This is useful if you need
# to set the $PATH on login instead of just when a interactive shell is opened.
# (eg setting environment for apps not started by command line)
#

em_login() {
	local prog=$1
	if [ -r "$EM_DIR/$prog/.active" ]; then
		cp "$EM_DIR/$prog/"{.active,.login}
	fi
}


#
# Resolve version name
#

em_normalize_version() {
	local prog=$1
	local version=$2
	case $version in
		latest) version=`em_display_latest_version $prog` ;;
		stable)	version=`em_display_latest_stable_version $prog` ;;
	esac
	case $prog in
		node) version=${version#v} ;;
	esac
	echo "$version"
}


#
# Determine source archive url for <version>.
#

em_src_archive_url() {
	local prog=$1
	local version=$2
	local rv=""
	case $prog in
	 	node)
			rv="http://nodejs.org/dist/v${version}/node-v${version}.tar.gz"
	esac
	echo "$rv"
}


#
# Determine binary archive url for <version>.
#

em_bin_archive_url() {
	local prog=$1
	local version=$2
	local rv=""
	case $prog in
	 	node)
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
			rv="http://nodejs.org/dist/v${version}/node-v${version}-${os}-${arch}.tar.gz"
	esac
	echo "$rv"
}


#
# Compile and install <version> with with optional alias and compilation config
#

em_compile() {
	local prog=$1
	local version="`em_normalize_version $prog $2`"
	local alias=$3
	if [ -z $alias ]; then
		alias=$version
	fi
	local config=$4

	local dir="$EM_DIR/$prog/versions/$alias"
	if [ -d "$dir" ]; then
		em_error_log "$alias already exists!" && return
	fi

	local url="`em_src_archive_url $prog $version`"
	if [ -z $url ]; then
		em_error_log "no src archive for $prog $version" && return
	fi

	if ! em_url_ok $url; then
		em_error_log "cannot get" "$url" && return
	fi
	local archive="`basename $url`"
	local downloads="$EM_DIR/downloads"
	local sources="$EM_DIR/$prog/sources"
	local logfile="$sources/${archive%.tar.gz}.log"
	echo

	em_info_log compiling "$prog $version"

	em_info_log "create dir" "$dir"
	# mkdir -p "$dir"
	mkdir -p "$sources"

	(
	mkdir -p "$downloads";
	cd "$downloads";
	if [ ! -r "$archive" ]; then
		em_info_log fetch $url
		eval "$EM_GET $url" > "$archive"
		em_erase_line
	fi
	case $prog in
		node)	
			tar x -C "$sources" -f "$downloads/$archive" 
			cd "$sources/${archive%.tar.gz}"
			em_info_log "compile start" "use tail -f \"$logfile\" for feedback "
			if ! ./configure $config --prefix="$dir" > "$logfile" 2>&1; then
				em_error_log "Error on configuration. See $logfile for details"
				return 1
			fi
			if ! make > "$logfile" 2>&1; then
				em_error_log "Error on compilation. See $logfile for	details"
				return 1
			fi
		  if ! make install > "$logfile" 2>&1; then
			 	em_error_log "Error on instalation. See $logfile for details"
				return 1
			fi
			;;
	esac
	)
	if [ $? -ne 0 ]; then
		return
	fi

	em_info_log installed "$prog $version as '$alias'"
	echo -n "Would you like to create a default environment for '$alias'?(y/N) "
	local c=""
	read c
	em_erase_line
	case $c in 
		y|Y) em_add $prog $alias $alias ;;
 	esac
	echo
}


#
# Install version with an optional alias
#

em_install() {
	local prog=$1
	local version="`em_normalize_version $prog $2`"
	local alias=$3
	if [ -z $alias ]; then
		alias=$version
	fi

	local dir="$EM_DIR/$prog/versions/$alias"
	if [ -d "$dir" ]; then
		em_error_log "$alias already exists!" && return
	fi

	local url="`em_bin_archive_url $prog $version`"
	if [ -z $url ]; then
		em_warn_log "no binary dist" "$prog $version"
		em_compile $prog $version $alias
		return
	fi

	if ! em_url_ok $url; then
		em_warn_log "no binary dist" "$prog $version"
		em_compile $prog $version $alias
		return
	fi
		
	local archive="`basename $url`"
	local downloads="$EM_DIR/downloads"

	echo

	em_info_log installing "$prog $version"

	em_info_log "create dir" "$dir"
	mkdir -p "$dir"

	(
	# Run in a subshell so it won't affect the current shell cwd
	mkdir -p "$downloads";
	cd "$downloads";
	if [ ! -r "$archive" ]; then
		em_info_log fetch $url
		eval "$EM_GET $url" > "$archive"
	fi
	cd "$dir";
	case $prog in
		node)	tar x --strip 1 -C "$dir" -f "$downloads/$archive" ;;
	esac
	)
	em_erase_line

	em_info_log installed "$prog $version as '$alias'"
	echo -n "Would you like to create a default environment for '$alias'?(y/N)"
	local c=""
	read c
	em_erase_line
	case $c in 
		y|Y) em_add $prog $alias $alias ;;
 	esac
	echo
}


#
# Uninstall <version ...>
#
em_uninstall() {
	local prog=$1
	shift
	[ -z "$1" ] && em_error_log "version(s) required" && return
	local version=$1
	echo
	while test $# -ne 0; do
		local dir="$EM_DIR/$prog/versions/$version"
		local environments="`cat \"$dir/._environments\"`"
		if [ ! -z $environments ]; then
			echo "Some environments depend on '$version':"
			echo
			echo "$environments"
			echo
			echo "Remove those before uninstalling the version"
			echo
			return
		fi
		rm -rf "$dir"
		em_info_log uninstalled "$version"
		shift
		version=$1
	done
	echo
}


#
# Adds <environment> based on <version> 
#

em_add() {
	local prog=$1
	shift
	[ -z $1 ] && em_error_log "version required" && return
	[ -z $2 ] && em_error_log "environment needs a name" && return
	local version=$1
	local version_dir="$EM_DIR/$prog/versions/$version"
	if [ ! -d "$version_dir" ]; then
		em_error_log "version $version doesn't exist" && return
	fi
	local environment=$2
	local dir="$EM_DIR/$prog/environments/$environment"
	if [ -e "$dir" ]; then
		em_info_log activated "$prog $environment"
		echo && return
	fi
	mkdir -p "$dir"
	em_info_log "create dir" "$dir"
	(
	cd "$dir"
	cp -as "$version_dir/"* .
	)
	echo "$environment" >> "$version_dir/._environments"
	echo "$version" > "$dir/._version"
	em_info_log symlink "$version -> $environment"
	echo -n "Would you like to activate '$alias'?(y/N)"
	local c=""
	read c
	em_erase_line
	case $c in 
		y|Y) em_activate $prog $environment ;;
 	esac
}


#
# Remove <environment ...>
#

em_remove() {
	local prog=$1
	shift
	[ -z "$1" ] && em_error_log "environment(s) required" && return
	echo
	local environment=$1
	while test $# -ne 0; do
		local dir="$EM_DIR/$prog/environments/$environment"
		if [ ! -d "$dir" ]; then
			em_error_log "environment $environment not found" && return
		fi
		local version=`cat "$dir/._version"`
		local active=`em_get_current_environment $prog`
		if [ "$environment" = "$active" ]; then
			em_deactivate $prog
		fi
		rm -rf "$dir"
		local escaped=`em_escape_for_sed $environment`
		sed -i "/^$escaped\$/d" "$EM_DIR/$prog/versions/$version/._environments"
		em_info_log removed "$prog $environment"
		shift
		environment=$1
	done
	echo
}


#
# Output path for <environment>
#

em_display_path_for_environment() {
	local prog=$1
	shift
	[ -z "$1" ] && em_error_log "environment required" && return
	local environment=$1
	local p="$EM_DIR/$prog/environments/$environment"
	if test -f "$p"; then
		printf "$p"
	else
		em_error_log "$environment is not installed" && return
	fi
}

#
# Display the latest version of [PROGRAM] available.
#

em_display_latest_version() {
	local prog=$1
	case $prog in
		node)
			eval "$EM_GET http://nodejs.org/dist/" \
				| egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
				| sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
				| tail -n1
			;;
	esac
}


#
# Display the latest stable version of [PROGRAM] available.
#

em_display_latest_stable_version() {
	local prog=$1
	case $prog in
		node)
			eval "$EM_GET http://nodejs.org/dist/" \
				| egrep -o '[0-9]+\.\d*[02468]\.[0-9]+' \
				| sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
				| tail -n1
			;;
	esac
}


#
# Display the versions of [PROGRAM] available.
#

em_display_remote_versions() {
	local prog=$1
	local active=`em_get_current_environment`
	local versions=""
	case $prog in
		node)
			versions=`eval "$EM_GET 2> /dev/null http://nodejs.org/dist/" \
				| egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
				| sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
				| awk 'BEGIN{print}{ print "  " $1 }'`

			echo
			for v in $versions; do
				if [ "$active" = "$v" ]; then
					printf "  \033[36mο\033[0m $v \033[0m\n"
				else
					if [ -d "$EM_DIR/versions/$v" ]; then
						printf "    $v \033[0m\n"
					else
						printf "    \033[90m$v\033[0m\n"
					fi
				fi
			done
			echo
			;;
	esac
}


#
# Entry point
#

em() {
	# Ensure we have curl or wget
	test -z "$EM_GET" && em_error_log "curl or wget required" && return

	# Handle arguments
	if test $# -eq 0; then
		em_display_help && return
	fi
	local prog=$1
	shift
	case $prog in
		node) ;;
		-h|--help|help) em_display_help && return;;
		*) echo "Invalid program/option, enter 'em help' for usage info" && return ;;
	esac
	if test $# -eq 0; then
		em_display_environments $prog && return
	fi
	local cmd=$1
	shift
	case $cmd in
		compile) em_compile $prog $@ ;;
		install) em_install $prog $@ ;;
		uninstall) em_uninstall $prog $@ ;;
		add|+) echo && em_add $prog $@ && echo ;;
		rm|-) em_remove $prog $@ ;;
		activate) echo && em_activate $prog $@ && echo ;;
		deactivate) echo && em_deactivate $prog && echo ;;
		bin|which) em_display_path_for_environment $prog ;;
		login) em_login $prog ;;
		ls|list) em_display_remote_versions $prog ;;
		prev) em_activate_previous $prog ;;
		*) echo "Invalid command, enter 'em help' for usage info" ;;
	esac
}

for prog in node; do
	[ -r "$EM_DIR/$prog/.active" ] && em_activate $prog `cat "$EM_DIR/$prog/.active"` > /dev/null
done
