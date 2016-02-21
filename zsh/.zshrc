# Title: zshrc
# Author: Thiago de Arruda (github.com/tarruda)
# Description:
#   This file is sourced by zsh when started as a interactive shell(-i).

# Modules {{{

zmodload zsh/pcre
zmodload zsh/complist
zmodload zsh/zutil

# }}}
# History {{{
setopt histignorealldups

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=$ZDOTDIR/.zsh_history

# }}}
# Options {{{

setopt auto_cd # change dir by typing the dir name
setopt auto_pushd # change dir push to directory stack automatically
setopt pushd_ignore_dups # dont push duplicates to directory stack
setopt rm_star_wait # wait 10 seconds before really executing 'rm -rf *'
setopt interactive_comments # allow comments in interactive shells

# }}}
# Prompt {{{

autoload -U colors && colors
autoload -U promptinit
setopt prompt_subst

PROMPT='%n%{$fg[yellow]%}@%{$reset_color%}%m %{$fg[blue]%}::%{$reset_color%} %2~ %{$fg[green]%}»%{$reset_color%} '
if [[ -n $MINGW64_ENV ]]; then
	PROMPT="(mingw-x64)$PROMPT"
elif [[ -n $MINGW32_END ]]; then
	PROMPT="(mingw-i686)$PROMPT"
fi
# Display return code of the last command
# RPROMPT='%{$?%}'

# }}}
# Zle {{{


# Set vi-mode and create a few additional Vim-like mappings
bindkey -v
bindkey "^?" backward-delete-char
bindkey -M vicmd "^R" redo
bindkey -M vicmd "u" undo
bindkey -M vicmd "ga" what-cursor-position
bindkey -M vicmd '^p' history-beginning-search-backward
bindkey -M vicmd '^n' history-beginning-search-forward
bindkey -M vicmd '/' history-incremental-search-forward
bindkey -M vicmd '?' history-incremental-search-backward

# Allows editing the command line with an external editor
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd "v" edit-command-line

setopt no_beep

# }}}
# Completion system {{{

# set directory containing custom completion functions
comp_dir=$ZDOTDIR/completion
if [[ -d $comp_dir ]]; then
	fpath=($comp_dir $fpath)
fi
unset comp_dir
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _ignored _approximate _correct
# don't need prefix when completing approximately
zstyle ':completion::approximate*:*' prefix-needed false
# more errors allowed for large words and fewer for small words
zstyle ':completion:*:approximate:*' max-errors 'reply=(  $((  ($#PREFIX+$#SUFFIX)/3  ))  )'
# Errors format
zstyle ':completion:*:corrections' format '%B%d (errors %e)%b'
# Don't complete stuff already on the line
zstyle ':completion::*:(rm):*' ignore-line true
# Don't complete directory we are already in (../here)
zstyle ':completion:*' ignore-parents parent pwd
#
zstyle ':completion:*' expand suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format '%d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'r:|[._-]=* r:|=* l:|=*'
if which dircolors &> /dev/null; then
	zstyle ':completion:*' menu select=2 eval "$(dircolors -b)"
fi
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' squeeze-slashes true
# ignore extensions when completing edit commands
zstyle ":completion:*:*:(vim|vi|e):*:*files" ignored-patterns '(*~|*.(o|swp|swo|tgz|tbz|tar.(gz|bz2|xz)))'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:gdb:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:gdb:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# initialize the completion system
autoload -Uz compinit
compinit

# }}}
# Functions {{{

fpath=($ZDOTDIR/functions/*(/N) $fpath)
# autoload all public functions
for file in $ZDOTDIR/functions/*/*(.N:t); do
	autoload -U $file
done
unset file

# wrapper for psql/pg_top that sets some default options
psql() {
	o_user=(-U postgres)
	o_host=(-h localhost)
	zparseopts -D -K U:=o_user -username:=o_user h=:o_host -hostname:=o_host
	PSQL_EDITOR='vim +"setf sql"' command psql -U $o_user[2] -h $o_host[2]\
		"$@"
}

pg_top() {
	o_user=(-U postgres)
	o_host=(-h localhost)
	zparseopts -D -K U:=o_user -username:=o_user h=:o_host -hostname:=o_host
	command pg_top -U $o_user[2] -h $o_host[2] "$@"
}

# Start working on a pull request, this requires a .git/user-repo file
# containing the string "user/repository"
pr() {
	if [[ ! -r .git/user-repo ]]; then
		echo "Need to setup user/repo" >&2
		return 1
	fi
	local user_repo=$(< .git/user-repo)
	local pr_num=$1
	if [[ -z $pr_num ]]; then
		echo "Need the pull request number" >&2
		return 1
	fi
	local branch=merge-pr-$pr_num
	if [[ -e .git/refs/heads/$branch ]]; then
		echo "Already working on pull request $pr_num, delete branch '$branch' and try again" >&2
		return 1
	fi
	(
	set -e
	local user_repo=$(< .git/user-repo)
	git checkout -b $branch
	curl "https://patch-diff.githubusercontent.com/raw/$(< .git/user-repo)/pull/$pr_num.diff" 2> /dev/null | git am --3way
	)
}

# Finish working on a pull request, besides the .git/user-repo file,
# this requires a .git/ghtok file containing the oauth token for accessing the
# repository
mpr() {
	if [[ ! -r .git/user-repo ]]; then
		echo "Need to setup user/repo" >&2
		return 1
	fi
	local user_repo=$(< .git/user-repo)
	if [[ ! -r .git/ghtok ]]; then
		echo "Need to setup oauth token" >&2
		return 1
	fi
	local ghtok=$(< .git/ghtok)
	local pr_num=$1
	if [[ -z $pr_num ]]; then
		echo "Need the pull request number" >&2
		return 1
	fi
	local branch=merge-pr-$pr_num
	if [[ ! -e .git/refs/heads/$branch ]]; then
		echo "Not working on $pr_num" >&2
		return 1
	fi
	(
	set -e
	echo "Will push commits and comment/close on PR $pr_num"
	git checkout master
	echo "Retrieving the PR title..."
	local pr_title="$(curl https://api.github.com/repos/$user_repo/issues/$pr_num 2> /dev/null | sed -n -e 's/.*"title":\s\+"\([^"]\+\)".*/\1/gp')"
	git merge --no-ff -m "Merge pull request #$pr_num '$pr_title'" $branch
	git branch -D $branch
	git log --graph --decorate --pretty=oneline --abbrev-commit --all --max-count=20
	echo "Continue with the merge?[y/N]"
	local confirm
	read confirm
	if [[ $confirm != "y" ]]; then
		echo "Merge cancelled" >&2
		git reset --hard HEAD~1
		exit 1
	fi
	)
}

cpr() {
	if [[ ! -r .git/user-repo ]]; then
		echo "Need to setup user/repo" >&2
		return 1
	fi
	local user_repo=$(< .git/user-repo)
	if [[ ! -r .git/ghtok ]]; then
		echo "Need to setup oauth token" >&2
		return 1
	fi
	local ghtok=$(< .git/ghtok)
	local pr_num=$1
	if [[ -z $pr_num ]]; then
		echo "Need the pull request number" >&2
		return 1
	fi
	git push
	curl \
		-X POST \
		-H "Authorization: token $ghtok"  \
		-d '{"body": ":+1: merged, thanks"}' \
		"https://api.github.com/repos/$user_repo/issues/$pr_num/comments" > /dev/null
	curl \
		-X PATCH \
		-H "Authorization: token $ghtok"  \
		-d '{"state": "closed"}' \
		"https://api.github.com/repos/$user_repo/issues/$pr_num" > /dev/null
	echo "Done"
}

# Print the stack trace of a core file.
# From http://www.commandlinefu.com/commands/view/4039/print-stack-trace-of-a-core-file-without-needing-to-enter-gdb-interactively
# Usage: corebt program corefile
corebt() {
	command gdb -q -n -batch -ex bt -c "$2" "$1"
}

# Open disassembly of function with original source code in comments
dis() {
	command gdb -q -n -batch -ex "set disassembly-flavor intel" \
	 	-ex "disassemble /m $1" $2 | sed -e 's/^[0-9a-zA-Z]/;\0/g' \
	 	-e 's/#/;/g' | vim -c 'setf asm' -c 'set syntax=nasm' -
}

# # wrapper for reading man pages

# man() {
# 	local pager=$PAGER
# 	if which vim &> /dev/null; then
# 		read pager <<- EOF
# 		zsh -c \"col -b -x | vim -R \
# 			--cmd 'let g:disable_addons = 1' \
# 			-c 'set ft=man nomod nolist nomodifiable' \
# 			-c 'set nonumber norelativenumber' \
# 			-c 'map q :q<cr>' \
# 			-c 'map <space> <c-d>' \
# 			-c 'map b <c-u>' -\"
# 		EOF
# 	fi
# 	PAGER=$pager command man "$@"
# }

# }}}
# Aliases {{{

alias ptrace-enable='sudo sh -c "echo 0 > /proc/sys/kernel/yama/ptrace_scope"'
case $OSTYPE in
	*bsd*|*darwin*)
		# Make freebsd ls colors look like linux ls
		# src: http://www.puresimplicity.net/~hemi/freebsd/misc.html
		export CLICOLOR="YES";
		export LSCOLORS="ExGxFxdxCxDxDxhbadExEx"; 
		alias l="command ls -G $@"
		alias ls=l
		alias la='l -lah $@'
		alias p='ps -auxww'
		;;
	*)
		alias l="command ls --color=auto $@"
		alias ls=l
		alias la="l -lah $@"
		alias p='ps -ef'
		;;
esac
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias d='dirs -v | head -10'
# alias gvim='pynvim -g --'
# alias vim='pynvim --'
# alias vi='pynvim --'
alias e=vi

# }}}
# Debian/Ubuntu {{{

# Command-not-found(ubuntu/debian)
if [[ -x /usr/lib/command-not-found ]]; then

	cnf_preexec() {
		typeset -g cnf_command="${1%% *}"
	}

	cnf_precmd() {
		if (( $? == 127 )) && [[ -n $cnf_command && -x /usr/lib/command-not-found ]]; then
			if ! whence -- $cnf_command >& /dev/null; then
				/usr/bin/python /usr/lib/command-not-found -- $cnf_command
			fi
			unset cnf_command
		fi
	}
	typeset -ga preexec_functions
	typeset -ga precmd_functions
	preexec_functions+=cnf_preexec
	precmd_functions+=cnf_precmd
fi

# }}}
# openssl {{{

raw-hexdump() {
	xxd -p | tr -d '\n'
}

random-key-256() {
	head -c 32 < /dev/urandom
}

# encrypt/decrypt utility using key taken from the first argument or stdin's 
# first 32 bytes. example:
# KEY=$(random-key-256)
# (echo -n $KEY; echo hello) | (echo -n $KEY; raw-aes256-enc) | raw-aes256-dec
raw-aes256-enc() {
	local key
	local o_key
	o_key=(-k)
	zparseopts -D -K -- k:=o_key
	key=$o_key[2]
	if [[ -z $o_key[2] ]]; then
		# no key passed as argument, decrypt using the first 32 bytes from stdin
		key=$(head -c 32 | raw-hexdump)
	fi
	local iv=$(head -c 16 </dev/urandom | raw-hexdump)
	echo -E -n $iv | xxd -p -r
	command openssl aes-256-cbc -e -iv $iv -K $key
}

raw-aes256-dec() {
	local key
	local o_key
	o_key=(-k)
	zparseopts -D -K -- k:=o_key
	key=$o_key[2]
	if [[ -z $o_key[2] ]]; then
		# no key passed as argument, decrypt using the first 32 bytes from stdin
		key=$(head -c 32 | raw-hexdump)
	fi
	local iv=$(head -c 16 | raw-hexdump)
	command openssl aes-256-cbc -d -iv $iv -K $key
}

# }}}
# Music {{{
beet-query() {
	local cmd query
	local -a o_limit o_shuffle o_path
	o_limit=(-l 50)
	zparseopts -K -D -- l:=o_limit s=o_shuffle p=o_path
	query="$@"
	if [[ -n $o_path[1] ]]; then
		query="-p $@"
	fi
	
	if [[ -n $o_shuffle[1] ]]; then
		cmd="random -e"
		if [[ -n $o_limit[2] ]]; then
			cmd="$cmd -n $o_limit[2]"
		fi
		cmd="$cmd $query"
	else
		cmd="list $query"
		if [[ -n $o_limit[2] ]]; then
			cmd="$cmd | head -n $o_limit[2]"
		fi
	fi
	if [[ -n $o_path[1] ]]; then
		eval "command beet $cmd" | sed "s:$HOME/Music/::"
	else
		eval "command beet $cmd"
	fi
}

mpd-play() {
	mpc clear
	beet-query "$@" | mpc add
	mpc play
}
# }}}
# Lxc {{{
if which lxc-create &> /dev/null; then
	lxc-create() { HOME=/data/lxc command lxc-create "$@" }
	lxc-destroy() { HOME=/data/lxc command lxc-destroy "$@" }
	lxc-start() { HOME=/data/lxc command lxc-start "$@" }
	lxc-stop() { HOME=/data/lxc command lxc-stop "$@" }
	lxc-autostart() { HOME=/data/lxc command lxc-autostart "$@" }
	lxc-attach() { HOME=/data/lxc command lxc-attach "$@" }
	lxc-ls() { HOME=/data/lxc command lxc-ls "$@" }
	lxc-info() { HOME=/data/lxc command lxc-info "$@" }
	lxc-snapshot() { HOME=/data/lxc command lxc-snapshot "$@" }
	lxc-clone() { HOME=/data/lxc command lxc-clone "$@" }
fi

# }}}
# Encfs {{{

# mount many encfs volumes using a single key
decrypt() {
	local p="$HOME/.encfs/mounts.txt"
	if [ -r "$p" ]; then
		echo "Enter the encryption key:"
		read -s key
		exec 3<"$p"
		local line=
		while read -u 3 line; do
			line=(${(s: :)line})
			if [ ${#line} -ne 2 ]; then
				echo "invalid line '$line'" >&2
				return 1
			fi
			local src=${~line[1]} 
			if [ ! -r "${src}/.encfs6.xml" ]; then
				echo "invalid source '$src'"
				return 1
			fi
			local tgt=${~line[2]}
			if [ ! -d "${tgt}" ]; then
				echo "invalid target '$tgt'"
				return 1
			fi
			echo "$key" | encfs -S "$src" "$tgt"
			if [ $? -eq 0 ]; then
				echo "mounted $src on $tgt"
			else
				return 1
			fi
		done
		exec 3>&-
		echo "done"
	fi
}

# }}}
# Programs {{{

# BURL (Better CURL) {{{

alias GET='burl GET'
alias HEAD='burl -I'
alias POST='burl POST'
alias PUT='burl PUT'
alias PATCH='burl PATCH'
alias DELETE='burl DELETE'
alias OPTIONS='burl OPTIONS'

# }}}

# }}}
# Tmux {{{

if ! [[ -z $TMUX || $TERM != tmux ]]; then
	# vim () { command vim "$@" }

	mutt() {
		TERM=screen-256color command mutt -e "set editor='TERM=tmux vim'" "$@"
	}

	weechat() {
		TERM=screen-256color command weechat-curses "$@"
	}

	# gdb() {
	# 	GDB=screen-256color command gdb "$@"
	# }

	# tgdb() {
	# 	TERM=screen-256color command gdb -tui "$@"
	# }

	# cgdb() {
	# 	TERM=screen-256color command cgdb "$@"
	# }
fi

# }}}
# Git/Github {{{
git-restore-file () {
	local file=$1
	if [[ -z $file ]]; then
		print "Need a filename" >&2
		return 1
	fi
	git checkout $(git rev-list -n1 HEAD -- $file)^ $file
}

git-last-branches() {
	git for-each-ref --sort=-committerdate refs/heads/ | head -n10
}

install-github-tree() {
	(
	zmodload zsh/regex
	o_dir=(-d)
	o_tree=(-t master)

	zparseopts -D -K -- d:=o_dir t:=o_tree

	dir=$o_dir[2]
	tree=$o_tree[2]
	repo=$1

	if [[ ! $repo -regex-match "[^/]+/.+$" ]]; then
		echo "Repository must be in the form 'user/repo'" >&2
		return 1
	fi

	strip=0
	if [[ -n $dir ]]; then
		if [[ -e $dir ]]; then
			echo "'$dir' already exists" >&2
			return 1
		fi
		strip=1
		mkdir $dir
		cd $dir
	fi
	command curl -L "https://github.com/${repo}/archive/${tree}.tar.gz" | tar --strip-components=$strip -xvzf -
	)
}
# }}}
# Lua {{{

install-luaenv() {
	install-github-tree -d "$HOME/.luaenv" -t 'a5af8cda564e3d51a6e3db4b9e29ea825ba4235f' 'cehoffman/luaenv'
	mkdir -p "$HOME/.luaenv/plugins"
	install-github-tree -d "$HOME/.luaenv/plugins/lua-build" -t 'b3d8d8eb44f18c77964853d9fb4fe200af8dae1c' 'cehoffman/lua-build'
	mkdir -p "$ZDOTDIR/site-zshrc.d"
	cat > "$ZDOTDIR/site-zshrc.d/luaenv.zsh" <<-EOF
	export LUAENV_ROOT="\$HOME/.luaenv"
	export PATH="\$LUAENV_ROOT/bin:\$PATH"
	eval "\$(luaenv init -)"
	EOF
	mkdir "$HOME/.luaenv/cache"
}

install-lua() {
	local version='5.1.5'
	luaenv install $version
	luaenv global $version
	luaenv rehash
	local luarocks_version='2.2.0'
	local prefix="$LUAENV_ROOT/versions/$version"
	curl -R -L -O http://luarocks.org/releases/luarocks-${luarocks_version}.tar.gz
	tar xf luarocks-${luarocks_version}.tar.gz
	rm luarocks-${luarocks_version}.tar.gz
	cd luarocks-${luarocks_version}
	./configure --prefix="${prefix}" --with-lua="${prefix}"
	make
	make install
	# cat >> ${prefix}/etc/luarocks/config-*.lua <<- "EOF"
	cat >> ${HOME}/config.lua <<- "EOF"
	rocks_servers = {
	   "http://rocks.moonscript.org/"
	}
	EOF
}

# }}}
# Ruby {{{
install-rbenv() {
	install-github-tree -d "$HOME/.rbenv" -t '5b9e4f05846f6bd03b09b8572142f53fd7a46e62' 'sstephenson/rbenv'
	mkdir -p "$HOME/.rbenv/plugins"
	install-github-tree -d "$HOME/.rbenv/plugins/ruby-build" -t 'v20150506' 'sstephenson/ruby-build'
	mkdir -p "$ZDOTDIR/site-zshrc.d"
	cat > "$ZDOTDIR/site-zshrc.d/rbenv.zsh" <<-EOF
	export RBENV_ROOT="\$HOME/.rbenv"
	export PATH="\$RBENV_ROOT/bin:\$PATH"
	eval "\$(rbenv init -)"
	EOF
	mkdir "$HOME/.rbenv/cache"
}

install-ruby() {
	local version='1.9.3-p448'
	RUBY_CONFIGURE_OPTS='--enable-shared' rbenv install $version
	rbenv global $version
}

# }}}
# Python {{{
install-pyenv() {
	install-github-tree -d "$HOME/.pyenv" -t 'v20141211' 'yyuu/pyenv'
	mkdir -p "$ZDOTDIR/site-zshrc.d"
	cat > "$ZDOTDIR/site-zshrc.d/pyenv.zsh" <<-EOF
	export PYENV_ROOT="\$HOME/.pyenv"
	export PATH="\$PYENV_ROOT/bin:\$PATH"
	eval "\$(pyenv init -)"
	EOF
	mkdir "$HOME/.pyenv/cache"
}

install-python() {
	local o_version o_name o_flags version flags recipe_dir vname
	o_version=(-V)
	o_name=(-N)
	o_flags=(-E)
	zparseopts -D -K -- V:=o_version N:=o_name E:=o_flags
	if [[ -z $o_version[2] ]]; then
		print 'Version must be specified' >&2
		return 1
	fi
	flags=(${(z)o_flags[2]})
	recipe_dir="$PYENV_ROOT/plugins/python-build/share/python-build/"
	if [[ -n $o_name[2] && $o_name[2] != $o_version[2] ]]; then
		if [[ -e "$recipe_dir/$o_name[2]" ]]; then
			print 'Version name already exists' >&2
			return 1
		fi
		cp "$recipe_dir"/{$o_version[2],$o_name[2]}
		version=$o_name[2]
	else
		version=$o_version[2]
	fi
	vname=$version
  if [[ ${flags[(r)-g]} == '-g' ]]; then
		vname=${version}-debug
	fi
	# local patchdir="$PYENV_ROOT/plugins/python-build/share/python-build/patches/$version/Python-$version"
	# mkdir -p "$patchdir"
	PYTHON_CONFIGURE_OPTS='--enable-shared' CFLAGS='-DOPENSSL_NO_SSL2 -fPIC' LDFLAGS="-Wl,-rpath=$PYENV_ROOT/versions/$vname/lib" \
		pyenv install $flags -p $version <<-EOF
	diff --git a/Modules/_ssl.c b/Modules/_ssl.c
	index ee8c0e2..752b033 100644
	--- a/Modules/_ssl.c
	+++ b/Modules/_ssl.c
	@@ -374,7 +374,7 @@ newPySSLObject(PySocketSockObject *Sock, char *key_file, char *cert_file,
	
	     /* ssl compatibility */
	     options = SSL_OP_ALL & ~SSL_OP_DONT_INSERT_EMPTY_FRAGMENTS;
	-    if (proto_version != PY_SSL_VERSION_SSL2)
	+//    if (proto_version != PY_SSL_VERSION_SSL2)
	         options |= SSL_OP_NO_SSLv2;
	     SSL_CTX_set_options(self->ctx, options);
	EOF
	if [[ $version != $o_version[2] ]]; then
		rm "$recipe_dir/$version"
	fi
	pyenv global $vname
}
# }}}
# Perl {{{
install-plenv() {
	install-github-tree -d "$HOME/.plenv" -t '2.1.1' 'tokuhirom/plenv'
	mkdir -p "$HOME/.plenv/plugins"
	install-github-tree -d "$HOME/.plenv/plugins/perl-build" -t '1.05' 'tokuhirom/perl-build'
	mkdir -p "$ZDOTDIR/site-zshrc.d"
	cat > "$ZDOTDIR/site-zshrc.d/plenv.zsh" <<-EOF
	export PLENV_ROOT="\$HOME/.plenv"
	export PATH="\$PLENV_ROOT/bin:\$PATH"
	eval "\$(plenv init -)"
	EOF
	mkdir "$HOME/.plenv/cache"
}

install-perl() {
	version='5.18.1'
	plenv install $version -Duseshrplib
	plenv global $version
}
# }}}
# Node.js {{{
install-nodenv() {
	install-github-tree -d "$HOME/.nodenv" -t 'v0.2.0' 'oinutter/nodenv'
	mkdir -p "$HOME/.nodenv/plugins"
	install-github-tree -d "$HOME/.nodenv/plugins/node-build" -t '9672346518d54b007e7fa1018569326baa04af73' 'oinutter/node-build'
	mkdir -p "$ZDOTDIR/site-zshrc.d"
	cat > "$ZDOTDIR/site-zshrc.d/nodenv.zsh" <<-EOF
	export NODENV_ROOT="\$HOME/.nodenv"
	export PATH="\$NODENV_ROOT/bin:\$PATH"
	eval "\$(nodenv init -)"
	EOF
	mkdir "$HOME/.nodenv/cache"
}

install-node() {
	local version='iojs-1.6.1'
	nodenv install $version
	nodenv global $version
}
# }}}
# Misc {{{

autoload -U zcalc zsh-mime-setup
zsh-mime-setup

# }}}
# {{{ zshrc.d
#
if [[ -d $ZDOTDIR/zshrc.d ]]; then
	for script in $ZDOTDIR/zshrc.d/*.zsh(.N); do
		source $script
	done
	unset script
fi

# }}}
# Site initialization {{{
if [[ -r $ZDOTDIR/.site-zshrc ]]; then
	source $ZDOTDIR/.site-zshrc
fi

if [[ -d $ZDOTDIR/site-zshrc.d ]]; then
	for script in $ZDOTDIR/site-zshrc.d/*.zsh(.N); do
		source $script
	done
	unset script
fi
# }}}
# Plugins {{{
# Syntax highlighting {{{
# plugin=$ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# if [[ -r $plugin ]]; then
# 	source $plugin
# fi
# }}}
# History substring search {{{
plugin=$ZDOTDIR/zsh-history-substring-search/zsh-history-substring-search.zsh
if [[ -r $plugin ]]; then
	source $plugin
	# bind k and j for VI mode
	bindkey -M vicmd 'k' history-substring-search-up
	bindkey -M vicmd 'j' history-substring-search-down
fi
# }}}
# Autosuggestions {{{
plugin=$ZDOTDIR/zsh-autosuggestions/autosuggestions.zsh
if [[ -r $plugin ]]; then
	export ZLE_AUTOSUGGEST_SERVER_LOG_ERRORS=1
	source $plugin
	zle-line-init() {
		zle autosuggest-start
	}
	zle -N zle-line-init
	bindkey '^T' autosuggest-toggle
	bindkey '^F' vi-forward-blank-word
	bindkey '^f' vi-forward-word
fi
# }}}
unset plugin
# }}}

# if [[ -e /etc/zshenv || -e /etc/zsh/zshenv ]]; then
#        print "/etc/zshenv exists, you probably want to move it to /etc/zprofile"
# fi
