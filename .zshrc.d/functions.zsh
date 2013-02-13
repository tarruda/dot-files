fpath=(~/.zshrc.d/functions/*(/N) ~/.zshrc.d/functions/*/lib $fpath)

# autoload all public functions
for file in ~/.zshrc.d/functions/*/*(.N); do
	file=${file##*/}
	autoload -Uz $file
done

unset file saved_fpath
