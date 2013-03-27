@echo off
set FILE=%~f1 && set CYGWIN_X=1 && set DISPLAY=:0.0
T:\cygwin\bin\zsh.exe -l -c 'gvim -f $(cygpath -u ${FILE})'
