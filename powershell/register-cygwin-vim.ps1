# By default, HKEY_CLASSES_ROOT is not registered, so we have to do it now
# new-psdrive -psprovider registry -root hkey_classes_root -name hkcr
$ErrorActionPreference = "Stop"
# cd hkcr:\applications
$classes='hkcu:\software\classes'
$apps="$classes\applications"
$names="$classes\local settings\software\microsoft\windows\shell\muicache"
$cmd='D:\cygwin\home\tarruda\.dotfiles\cygwin-resources\edit-gvim.bat'
$icon='D:\cygwin\home\tarruda\.dotfiles\cygwin-resources\icons\vim.ico'
$filetypes=@(".txt", ".ps1", ".sh", ".py", ".cs", ".cpp", ".c", ".rb",
".zsh", ".bash", ".vbox", ".xml", ".yml", ".yaml", ".bat")

function test-registryvalue($regkey, $name) {
  get-itemproperty $regkey $name -ErrorAction SilentlyContinue |
    out-null
    $?
}

# register edit/open commands
cd $apps
if (test-path "$apps\cygwin-gvim.exe") {
  rm -recurse "$apps\cygwin-gvim.exe"
}
mkdir cygwin-gvim.exe
mkdir cygwin-gvim.exe\shell
mkdir cygwin-gvim.exe\shell\edit
mkdir cygwin-gvim.exe\shell\edit\command
cd cygwin-gvim.exe\shell\edit\command
set-itemproperty . '(Default)' "$cmd `"%1`""
cd ../../
mkdir open
mkdir open\command
cd open\command
set-itemproperty . '(Default)' "$cmd `"%1`""
# register the icon
cd $apps\cygwin-gvim.exe
mkdir defaulticon
cd defaulticon
set-itemproperty . '(Default)' $icon
# associate with filetypes
cd $apps\cygwin-gvim.exe
mkdir supportedtypes
cd supportedtypes
foreach ($ext in $filetypes) {
  new-itemproperty -Path . -name $ext -PropertyType string -value ''
}
# register a 'beautiful' application name
cd $names
if (test-registryvalue $names $cmd) {
  remove-itemproperty -path . -name $cmd
}
new-itemproperty -Path . -name $cmd -PropertyType string -value 'Cygwin gVim'
