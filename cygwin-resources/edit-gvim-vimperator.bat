@echo off
set FILE=%~f1 && set X11_WINDOWS=1 && set DISPLAY=:0.0
D:\cygwin\bin\zsh.exe -l -c 'gvim -f $(cygpath -u ${FILE})'
