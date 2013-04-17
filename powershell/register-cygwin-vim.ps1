# Sources:
# http://msdn.microsoft.com/en-us/library/windows/desktop/ee872121(v=vs.85).aspx
# http://msdn.microsoft.com/en-us/library/cc144158(VS.85).aspx
# http://msdn.microsoft.com/en-us/library/windows/desktop/cc144101(v=vs.85).aspx
# http://stackoverflow.com/questions/1387769/create-registry-entry-to-associate-file-extension-with-application-in-c
$ErrorActionPreference = "Stop"
$classes="hkcu:\software\classes"
$apps="$classes\applications"
$cmd='D:\cygwin\home\tarruda\.dotfiles\cygwin-resources\edit-gvim.bat'
$friendlyname='gVim (Cygwin)'
$icon='D:\cygwin\home\tarruda\.dotfiles\cygwin-resources\icons\vim.ico'
$filetypes=@(".txt", ".ps1", ".sh", ".py", ".cs", ".cpp", ".c", ".rb",
    ".zsh", ".bash", ".vbox", ".xml", ".yml", ".yaml", ".bat")

if (test-path "$apps\cygwin-gvim.exe") {
  # cleanup
  remove-item -recurse "$apps\cygwin-gvim.exe"
}
# register open commands to know filetypes
new-item -path "$apps\cygwin-gvim.exe\shell\open\command" -value "$cmd `"%1`"" -force
# add a context menu item(edit with gVim) to every file in windows explorer
new-item -path "$classes\*\shell\Edit with $friendlyname\command" -value "$cmd `"%1`"" -force
# friendly name for the 'open with' dialog
new-itemproperty -path "$apps\cygwin-gvim.exe\shell\open" -name 'FriendlyAppName' -value $friendlyname
# register the icon
# FIXME this has no effect, need to find a way to associate icons with a bat file 
new-item -path "$apps\cygwin-gvim.exe\DefaultIcon" -value $icon -type expandstring
# register supported file extensions
new-item -path "$apps\cygwin-gvim.exe\SupportedTypes"
foreach ($ext in $filetypes) {
  new-itemproperty -path "$apps\cygwin-gvim.exe\SupportedTypes" -name $ext -PropertyType string -value ''
}
