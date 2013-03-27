@echo off
set FILE=%~f1 && set DISPLAY=:0.0
T:\cygwin\bin\run.exe /bin/zsh -l -c 'gvim $(cygpath -u ${FILE})'
