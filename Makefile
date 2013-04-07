link:
	@./install/symlinks install

unlink:
	@./install/symlinks uninstall

fonts:
	@./install/fonts

terminfo:
	@./install/terminfo

.PHONY: link unlink fonts terminfo
