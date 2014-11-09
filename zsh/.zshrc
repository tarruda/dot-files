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

PROMPT='%m %{$fg[blue]%}::%{$reset_color%} %2~ %{$fg[green]%}»%{$reset_color%} '
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
	PSQL_EDITOR='vim -X +"setf sql"' command psql -U $o_user[2] -h $o_host[2]\
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
	curl "https://github.com/$(< .git/user-repo)/pull/$pr_num.patch" 2> /dev/null | git am --3way
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

# wrapper for reading man pages

man() {
	local pager=$PAGER
	if which vim &> /dev/null; then
		read pager <<- EOF
		zsh -c \"col -b -x | vim -X -R \
			--cmd 'let g:disable_addons = 1' \
			-c 'set ft=man nomod nolist nomodifiable' \
			-c 'set nonumber norelativenumber' \
			-c 'map q :q<cr>' \
			-c 'map <space> <c-d>' \
			-c 'map b <c-u>' -\"
		EOF
	fi
	PAGER=$pager command man "$@"
}

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
alias vim=nvim
alias vi=vim
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
# SSH/GnuPG {{{

if ! which gpg-agent &> /dev/null; then
	# Invoke ssh-add on demand, not needed if using gnupg-agent(but ssh-add has to
	# be invoked one time to add it to the list of gnupg-agent managed keys)
	git() {
		case $1 in
			pull|push|fetch)
				local remote=$2
				if [[ -z $remote ]]; then
					# remote wasn't specified so we have to find it by looking at
					# which remote branch the current branch is tracking
					local current_branch="`command git branch | grep '^*'`"
					current_branch=${current_branch#\*\ }
					local line=
					command git for-each-ref --format='%(refname:short)<-%(upstream:short)' refs/heads | while read line; do
					if [[ ${line%%\<\-*} == $current_branch ]]; then
						remote=${line#*<-}
						remote=${remote%%/*}
						break
					fi
				done
			fi
			# now find out the url
			local grepLine='Fetch'
			[[ $1 == push ]] && grepLine='Push'
			local url="`git remote show "$remote" -n | grep "$grepLine"`"
			url="${url#*$grepLine*\:\ }"
			case $url in
				*@*|ssh://*)
					# needs SSH key, so invoke ssh-add if needed
					ssh-add -l &> /dev/null || ssh-add
			esac
			;;
	esac

	command git "$@"
}
ssh() {
	if ssh-add -l &> /dev/null || ssh-add; then
		command ssh "$@"
	fi
}
fi

# }}}
# Tmux {{{

if ! [[ -z $TMUX || $TERM != tmux ]]; then
	# vim () { command vim -X "$@" }

	mutt() {
		TERM=screen-256color command mutt -e "set editor='TERM=tmux vim -X'" "$@"
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
# Ruby {{{
install-rbenv() {
	install-github-tree -d "$HOME/.rbenv" -t '14bc162ca606e0c61da8d82e1b99b0946d7be13f' 'sstephenson/rbenv'
	mkdir -p "$HOME/.rbenv/plugins"
	install-github-tree -d "$HOME/.rbenv/plugins/ruby-build" -t 'v20140225' 'sstephenson/ruby-build'
	mkdir -p "$ZDOTDIR/site-zshrc.d"
	cat > "$ZDOTDIR/site-zshrc.d/rbenv.zsh" <<-EOF
	export RBENV_ROOT="\$HOME/.rbenv"
	export PATH="\$RBENV_ROOT/bin:\$PATH"
	eval "\$(rbenv init -)"
	EOF
}

install-ruby() {
	local version='1.9.3-p448'
	RUBY_CONFIGURE_OPTS='--enable-shared' rbenv install $version
	echo $version > "$HOME/.ruby-version"
}

# }}}
# Python {{{
install-pyenv() {
	install-github-tree -d "$HOME/.pyenv" -t 'v20140615' 'yyuu/pyenv'
	mkdir -p "$ZDOTDIR/site-zshrc.d"
	cat > "$ZDOTDIR/site-zshrc.d/pyenv.zsh" <<-EOF
	export PYENV_ROOT="\$HOME/.pyenv"
	export PATH="\$PYENV_ROOT/bin:\$PATH"
	eval "\$(pyenv init -)"
	EOF
}

install-python() {
	local version='2.7.7'
	PYTHON_CONFIGURE_OPTS='--enable-shared' CFLAGS='-fPIC' LDFLAGS="-Wl,-rpath=$PYENV_ROOT/versions/$version/lib" pyenv install $version
	echo $version > "$HOME/.python-version"
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
}

install-perl() {
	version='5.18.1'
	plenv install $version -Duseshrplib
	echo $version > ~/.perl-version
}
# }}}
# Node.js {{{
install-nodenv() {
	install-github-tree -d "$HOME/.nodenv" -t 'v0.2.0' 'oinutter/nodenv'
	mkdir -p "$HOME/.nodenv/plugins"
	install-github-tree -d "$HOME/.nodenv/plugins/node-build" -t 'c3642328f264429982f5d7623f8a894cc741962c' 'oinutter/node-build'
	mkdir -p "$ZDOTDIR/site-zshrc.d"
	cat > "$ZDOTDIR/site-zshrc.d/nodenv.zsh" <<-EOF
	export NODENV_ROOT="\$HOME/.nodenv"
	export PATH="\$NODENV_ROOT/bin:\$PATH"
	eval "\$(nodenv init -)"
	EOF
}

install-node() {
	local version='0.10.32'
	nodenv install $version
	echo $version > ~/.node-version
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
