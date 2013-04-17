@echo off
set FILE=%~f1
D:\cygwin\bin\tcp-command.exe 127.0.0.1 gvim $(cygpath -u %FILE:\=\\\\%)
