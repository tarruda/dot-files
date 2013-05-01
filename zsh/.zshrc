# Title: zshrc
# Author: Thiago de Arruda (github.com/tarruda)
# Description:
#   This file is sourced by zsh when started as a interactive shell(-i).

# Modules {{{

zmodload zsh/pcre
zmodload zsh/complist
zmodload zsh/zutil
zmodload zsh/zpty

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

# }}}
# Prompt {{{

autoload -U colors && colors
autoload -U promptinit

PROMPT='%m :: %2~ %B»%b '
if [[ -n $MINGW64_ENV ]]; then
	PROMPT="(mingw-x64)$PROMPT"
elif [[ -n $MINGW32_END ]]; then
	PROMPT="(mingw-i686)$PROMPT"
fi

# }}}
# Zle {{{

# Set vi-mode and create a few additional Vim-like mappings
bindkey -v
bindkey "^?" backward-delete-char
bindkey -M vicmd "^R" redo
bindkey -M vicmd "u" undo
bindkey -M vicmd "ga" what-cursor-position
bindkey -M viins '^p' history-beginning-search-backward
bindkey -M vicmd '^p' history-beginning-search-backward
bindkey -M viins '^n' history-beginning-search-forward
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
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
# don't need prefix when completing approximately
zstyle ':completion::approximate*:*' prefix-needed false
# more errors allowed for large words and fewer for small words
zstyle ':completion:*:approximate:*' max-errors 'reply=(  $((  ($#PREFIX+$#SUFFIX)/3  ))  )'
# Errors format
zstyle ':completion:*:corrections' format '%B%d (errors %e)%b'
# Don't complete stuff already on the line
zstyle ':completion::*:(rm|vi):*' ignore-line true
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
zstyle ':completion:*' menu select=2 eval "$(dircolors -b)"
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' squeeze-slashes true
# ignore extensions when completing edit commands
zstyle ":completion:*:*:(vim|vi|e):*:*files" ignored-patterns '(*~|*.(o|swp|swo|tgz|tbz|tar.(gz|bz2|xz)))'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:(kill|strace):*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

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
	command psql -U $o_user[2] -h $o_host[2] "$@"
}

pg_top() {
	o_user=(-U postgres)
	o_host=(-h localhost)
	zparseopts -D -K U:=o_user -username:=o_user h=:o_host -hostname:=o_host
	command pg_top -U $o_user[2] -h $o_host[2] "$@"
}

# }}}
# Aliases {{{

case $OSTYPE in
	*bsd*)
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
	# Invoke ssh-add on demand, not needed if using gpg-agent
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

if [[ -z $TMUX || $TERM != tmux ]]; then
	alias vi=vim
	irssi() {
		command irssi --home=$DOTDIR/irssi "$@"
	}
else
	vim () { command vim -X "$@" }
	vi() { zsh $DOTDIR/tmux/scripts/vim-tmux-open.zsh "$@" }

	# It seems irssi/mutt breaks with my custom terminfo
	irssi() {
		TERM=screen-256color command irssi --home=$DOTDIR/irssi "$@"
	}
	mutt() {
		TERM=screen-256color command mutt -e "set editor='TERM=tmux vim -X'" "$@"
	}
fi

alias e=vi

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
# }}}
