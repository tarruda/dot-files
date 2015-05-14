all: link fonts hooks

link:
	@./install/symlinks install

unlink:
	@./install/symlinks uninstall

fonts:
	@./install/fonts

terminfo:
	@./install/terminfo

hooks:
	ln -s $$DOTDIR/hooks ~/.hooks

.PHONY: all link unlink fonts terminfo hooks
