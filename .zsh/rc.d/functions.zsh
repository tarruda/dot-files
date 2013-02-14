fpath=($ZDOTDIR/functions/*(/N) $fpath)

# autoload all public functions
for file in $ZDOTDIR/functions/*/*(.N:t); do
	autoload -U $file
done

unset file
