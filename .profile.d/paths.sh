# Include git-extras
if [ -d "$HOME/.git-extras/bin" ] ; then
    PATH="$HOME/.git-extras/bin:$PATH"
fi

# Include custom commands
if [ -d "$HOME/.bin" ] ; then
    PATH="$HOME/.bin:$PATH"
fi

export PATH
