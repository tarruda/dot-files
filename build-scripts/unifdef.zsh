#!/bin/zsh -e

cat > /tmp/defines.h << "EOF"
#define FEAT_ARABIC
#define FEAT_AUTOCHDIR
#define FEAT_AUTOCMD
#define FEAT_BROWSE
#define FEAT_BROWSE_CMD
#define FEAT_BYTEOFF
#define FEAT_CINDENT
#define FEAT_CMDHIST
#define FEAT_CMDL_COMPL
#define FEAT_CMDL_INFO
#define FEAT_CMDWIN
#define FEAT_COMMENTS
#define FEAT_COMPL_FUNC
#define FEAT_CONCEAL
#define FEAT_CON_DIALOG
#define FEAT_CRYPT
#define FEAT_CSCOPE
#define FEAT_CURSORBIND
#define FEAT_DIFF
#define FEAT_DIGRAPHS
#define FEAT_EVAL
#define FEAT_EX_EXTRA
#define FEAT_FIND_ID
#define FEAT_FKMAP
#define FEAT_FLOAT
#define FEAT_FOLDING
#define FEAT_GETTEXT
#define FEAT_HANGULIN
#define FEAT_INS_EXPAND
#define FEAT_JUMPLIST
#define FEAT_KEYMAP
#define FEAT_LANGMAP
#define FEAT_LINEBREAK
#define FEAT_LISP
#define FEAT_LISTCMDS
#define FEAT_LOCALMAP
#define FEAT_MBYTE
#define FEAT_MENU
#define FEAT_MODIFY_FNAME
#define FEAT_MOUSE
#define FEAT_MOUSE_DEC
#define FEAT_MOUSE_NET
#define FEAT_MOUSE_SGR
#define FEAT_MOUSE_TTY
#define FEAT_MOUSE_URXVT
#define FEAT_MOUSE_XTERM
#define FEAT_MULTI_LANG
#define FEAT_PATH_EXTRA
#define FEAT_PERSISTENT_UNDO
#define FEAT_POSTSCRIPT
#define FEAT_PRINTER
#define FEAT_PROFILE
#define FEAT_QUICKFIX
#define FEAT_RELTIME
#define FEAT_RIGHTLEFT
#define FEAT_SCROLLBIND
#define FEAT_SEARCHPATH
#define FEAT_SEARCH_EXTRA
#define FEAT_SESSION
#define FEAT_SMARTINDENT
#define FEAT_SPELL
#define FEAT_STL_OPT
#define FEAT_SYN_HL
#define FEAT_TAG_BINS
#define FEAT_TAG_OLDSTATIC
#define FEAT_TERMRESPONSE
#define FEAT_TEXTOBJ
#define FEAT_TITLE
#define FEAT_USR_CMDS
#define FEAT_VERTSPLIT
#define FEAT_VIMINFO
#define FEAT_VIRTUALEDIT
#define FEAT_VISUAL
#define FEAT_VISUALEXTRA
#define FEAT_VREPLACE
#define FEAT_WAK
#define FEAT_WILDIGN
#define FEAT_WILDMENU
#define FEAT_WINDOWS
#define FEAT_WRITEBACK
#define FEAT_HUGE
#define FEAT_BIG
#define FEAT_NORMAL
#define FEAT_SMALL
#define FEAT_TINY
#define FEAT_WRITEBACKUP
#define VIM_BACKTICK           /* internal backtick expansion */

#undef __BORLANDC__
#undef PROTO
#undef NeXT
#undef VAXC
#undef macintosh
#undef __TANDEM
#undef _TANDEM_SOURCE
#undef _CRT_SECURE_NO_DEPRECATE
#undef _CRT_NONSTDC_NO_DEPRECATE
#undef __EMX__
#undef __CYGWIN__
#undef __sgi
#undef WIN32UNIX
#undef SOLARIS
#undef sun
#undef __CYGWIN32__
#undef _MSC_VER
#undef _AIX
#undef _AIX43
#undef WIN16
#undef DOS
#undef DOS16
#undef AMIGA
#undef VMS
#undef __APPLE__
#undef __POWERPC__
#undef __MINT__
#undef __QNX__
#undef MAXOS_CONVERT
#undef AZTEC_C
#undef SASC
#undef _DCC
#undef __TURBOC__
#undef __PARMS__
#undef __BEOS__
#undef __MRC__
#undef DOS32
#undef MSDOS
#undef DJGPP
#undef MAC
#undef MACOS
#undef OS2
#undef MACOS_CLASSIC
#undef MACOS_X_UNIX
#undef MACOSX
#undef MACOS_X
#undef FEAT_GUI_ENABLED
#undef FEAT_X11
#undef WIN32
#undef WIN3264
#undef MSWIN
#undef _WIN64
#undef __w64
#undef FEAT_EMACS_TAGS
#undef FEAT_MBYTE_IME
#undef DYNAMIC_GETTEXT
#undef USE_XIM
#undef FEAT_TEAROFF
#undef HAVE_XPM
#undef FEAT_TOOLBAR
#undef FEAT_GUI
#undef FEAT_GUI_W16
#undef FEAT_GUI_MSWIN
#undef FEAT_GUI_W32
#undef FEAT_GUI_ATHENA
#undef FEAT_GUI_GTK
#undef FEAT_GUI_MOTIF
#undef FEAT_GUI_MAC
#undef FEAT_GUI_PHOTON
#undef FEAT_GUI_TABLINE
#undef FEAT_GUI_DIALOG
#undef FEAT_GUI_TEXTDIALOG
#undef FEAT_BROWSE_CMD
#undef FEAT_BROWSE
#undef ALWAYS_USE_GUI
#undef FEAT_CW_EDITOR
#undef WANT_X11
#undef USE_XSMP
#undef DOS_MOUSE
#undef FEAT_MOUSE_PTERM
#undef FEAT_MOUSE_GPM
#undef FEAT_SYSMOUSE
#undef FEAT_CLIPBOARD
#undef FEAT_XCLIPBOARD
#undef FEAT_DND
#undef MSWIN_FIND_REPLACE
#undef MSWIN_FR_BUFSIZE 256
#undef FIND_REPLACE_DIALOG 1
#undef FEAT_CLIENTSERVER
#undef MCH_CURSOR_SHAPE
#undef FEAT_MOUSESHAPE
#undef MZSCHEME_GUI_THREADS
#undef FEAT_ARP
#undef FEAT_SIGNS
#undef FEAT_SIGN_ICONS
#undef FEAT_BEVAL
#undef FEAT_XFONTSET
#undef FEAT_BEVAL_TIP         /* balloon eval used for toolbar tooltip */
#undef FEAT_GUI_X11
#undef ALT_X_INPUT
#undef FEAT_FOOTER
#undef FEAT_FILTERPIPE
#undef EBCDIC
#undef HAVE_X11
#undef HAVE_OUTFUNTYPE
#undef SMALL_WCHAR_T
#undef HAVE_SS_BASE
#undef HAVE_DEV_PTC
#undef PTYRANGE0
#undef PTYRANGE1
#undef PTYMODE
#undef PTYGROUP
#undef HAVE_UTIL_DEBUG_H
#undef HAVE_UTIL_MSGI18N_H
#undef HAVE_X11_SUNKEYSYM_H
#undef HAVE_XM_XM_H
#undef HAVE_XM_XPMP_H
#undef HAVE_XM_TRAITP_H
#undef HAVE_XM_MANAGER_H
#undef HAVE_XM_UNHIGHLIGHTT_H
#undef HAVE_XM_JOINSIDET_H
#undef HAVE_XM_NOTEBOOK_H
#undef HAVE_X11_XPM_H
#undef HAVE_X11_XMU_EDITRES_H
#undef HAVE_X11_SM_SMLIB_H
#undef XPMATTRIBUTES_TYPE
#undef FEAT_LUA
#undef DYNAMIC_LUA
#undef FEAT_MZSCHEME
#undef FEAT_PERL
#undef DYNAMIC_PERL
#undef FEAT_PYTHON
#undef FEAT_PYTHON3
#undef DYNAMIC_PYTHON
#undef DYNAMIC_PYTHON3
#undef PY_NO_RTLD_GLOBAL
#undef PY3_NO_RTLD_GLOBAL
#undef FEAT_RUBY
#undef DYNAMIC_RUBY
#undef FEAT_TCL
#undef FEAT_SNIFF
#undef HAVE_POSIX_ACL
#undef HAVE_SOLARIS_ZFS_ACL
#undef HAVE_SOLARIS_ACL
#undef HAVE_AIX_ACL
#undef HAVE_GPM
#undef HAVE_SYSMOUSE
#undef FEAT_XIM
#undef FEAT_GUI_GNOME
#undef FEAT_KDETOOLBAR
#undef HAVE_GTK_MULTIHEAD
#undef X_LOCALE
#undef HAVE_SHL_LOAD
#undef FEAT_SUN_WORKSHOP
#undef FEAT_NETBEANS_INTG
#undef IN_PERL_FILE
#undef NBDEBUG
#undef USE_XSMP_INTERACT
#undef FEAT_CYGWIN_WIN32_CLIPBOARD
#undef HAVE_AVAILABILITYMACROS_H
EOF

root_remove=(
Makefile
configure
Contents
Contents.info
csdpmi4b.zip
farsi
Filelist
.hgignore
.hgtags
libs
nsis
pixmaps
README_amibin.txt
README_amibin.txt.info
README_amisrc.txt
README_amisrc.txt.info
README_ami.txt
README_ami.txt.info
README_bindos.txt
README_dos.txt
README_extra.txt
README_mac.txt
README_ole.txt
README_os2.txt
README_os390.txt
README_srcdos.txt
README_src.txt
README.txt
README.txt.info
README_unix.txt
README_vms.txt
README_w32s.txt
runtime.info
src.info
uninstal.txt
vimdir.info
Vim.info
vimtutor.bat
vimtutor.com
Xxd.info
)

src_remove=(
auto
bigvim64.bat
bigvim.bat
config.aap.in
config.h.in
config.mk.dist
config.mk.in
configure
configure.in
dehqx.py
dimm.idl
dosinst.c
dosinst.h
feature.h
glbl_ime.cpp
glbl_ime.h
gui_at_fs.c
gui_athena.c
gui_at_sb.c
gui_at_sb.h
gui_beval.c
gui_beval.h
gui.c
gui_gtk.c
gui_gtk_f.c
gui_gtk_f.h
gui_gtk_vms.h
gui_gtk_x11.c
gui.h
gui_mac.c
gui_motif.c
gui_photon.c
gui_w16.c
guiw16rc.h
gui_w32.c
gui_w32_rc.h
gui_w48.c
gui_x11.c
gui_x11_pm.h
gui_xmdlg.c
gui_xmebw.c
gui_xmebw.h
gui_xmebwp.h
gvim.exe.mnf
GvimExt
gvimtutor
if_lua.c
if_mzsch.c
if_mzsch.h
if_ole.cpp
if_ole.h
if_ole.idl
if_perlsfio.c
if_perl.xs
if_py_both.h
if_python3.c
if_python.c
if_ruby.c
if_sniff.c
pty.c
if_sniff.h
if_tcl.c
if_xcmdsrv.c
iid_ole.c
infplist.xml
INSTALL
INSTALLami.txt
INSTALLmac.txt
installman.sh
installml.sh
INSTALLpc.txt
INSTALLvms.txt
INSTALLx.txt
integration.c
integration.h
link.390
link.sh
main.aap
Make_bc3.mak
Make_bc5.mak
Make_cyg.mak
Make_dice.mak
Make_djg.mak
Make_dvc.mak
Make_ivc.mak
Make_manx.mak
Make_ming.mak
Make_mint.mak
Make_morph.mak
Make_mvc.mak
Make_os2.mak
Make_sas.mak
Make_vms.mms
Make_w16.mak
Makefile
mkinstalldirs
msvc2008.bat
msvc2010.bat
msvcsetup.bat
mysign
nbdebug.c
nbdebug.h
netbeans.c
os_amiga.c
os_amiga.h
os_beos.c
os_beos.h
os_beos.rsrc
osdef1.h.in
osdef2.h.in
osdef.sh
os_dos.h
os_mac_conv.c
os_mac.h
os_macosx.m
os_mac_rsrc
os_mac.rsr.hqx
os_mint.h
os_msdos.c
os_msdos.h
os_mswin.c
os_os2_cfg.h
os_qnx.c
os_qnx.h
os_vms.c
os_vms_conf.h
os_vms_fix.com
os_vms_mms.c
os_w32dll.c
termlib.c
dlldata.c
os_w32exe.c
os_win16.c
os_win16.h
os_win32.c
os_win32.h
memfile_test.c
winclip.c
pathdef.sh
README.txt
swis.s
tearoff.bmp
tee
toolbar.phi
toolcheck
tools16.bmp
tools.bmp
typemap
uninstal.c
vim16.def
vim16.rc
vim_alert.ico
vim.def
vim_error.ico
vim.ico
vim_icon.xbm
vim_info.ico
vimio.h
vim_mask.xbm
vim_quest.ico
vim.rc
vimrun.c
vimtbar.dll
vimtbar.h
vimtbar.lib
vim.tlb
vimtutor
VisVim
which.sh
workshop.c
workshop.h
wsdebug.c
wsdebug.h
xpm
xpm_w32.c
xpm_w32.h
xxd
)

proto_remove=(
termlib.pro
gui_beval.pro
gui_w32.pro
if_mzsch.pro
if_xcmdsrv.pro  
os_beos.pro
os_win32.pro
pty.pro
winclip.pro
gui_gtk.pro
gui_x11.pro
if_ole.pro
os_mac_conv.pro
gui_gtk_x11.pro
gui_xmdlg.pro
if_perl.pro
os_msdos.pro
os_mswin.pro
workshop.pro
gui_mac.pro
if_perlsfio.pro
netbeans.pro
gui_motif.pro
if_python3.pro
os_qnx.pro
gui_photon.pro
if_python.pro
gui.pro
if_ruby.pro
os_vms.pro
gui_athena.pro
gui_w16.pro
if_lua.pro
if_tcl.pro
os_amiga.pro
os_win16.pro
)

po_remove=(
Make_ming.mak
Make_mvc.mak
README_mingw.txt
README_mvc.txt
README.txt
)

testdir_remove=(
Make_vms.mms
python2
python3
python_after
python_before
python_x
vms.vim
dos.vim
amiga.vim
os2.vim
todos.vim
Make_amiga.mak
Make_dos.mak
Make_ming.mak
Make_os2.mak
main.aap
)

uncrustify_cfg=../neov/uncrustify.cfg
uncrustify_cfg=${uncrustify_cfg:a}

for file in $root_remove; do
	rm -rf $file
done

cd src
for file in $src_remove; do
	rm -rf $file
done

cd testdir
for file in $testdir_remove; do
	rm -rf $file
done
cd ..

cd po
for file in $po_remove; do
	rm -rf $file
done
cd ..

cd proto
for file in $proto_remove; do
	rm -rf $file
done

tmp=/tmp/processing-file
for file in *.pro; do
	print "processing $file"
	cp $file $tmp
	unifdef -e -k -x 2 -f /tmp/defines.h $tmp -o $file
	uncrustify -l c -c $uncrustify_cfg -f $file > $tmp
	cp $tmp $file
done
cd ..

# edit some files
sed -i '29,38d' blowfish.c
sed -i 's/while\ \+vim_iswhite(\*pat)/while (vim_iswhite(*pat))/g' if_cscope.c

for file in *.(c|h); do
	print "processing $file"
	# copy the file to a temporary location
	cp $file $tmp
	unifdef -e -k -x 2 -f /tmp/defines.h $tmp -o $file
	# if [[ $file != "quickfix.c" ]]; then
	uncrustify -l c -c $uncrustify_cfg -f $file > $tmp
	cp $tmp $file
	# fi
done

# now do a bunch of edits to make it compile
sed -i -f - vim.h << "EOF"
/\#\ define\ VIM__H/ {
	a\
/* Included when ported to cmake */\
/* This is needed to replace TRUE/FALSE macros by true/false from c99 */\
#include <stdbool.h>\
/* Some defines from the old feature.h */\
#define SESSION_FILE "Session.vim"\
#define MAX_MSG_HIST_LEN 200\
#define SYS_OPTWIN_FILE "$VIMRUNTIME/optwin.vim"\
#define RUNTIME_DIRNAME "runtime"\
/* end */
}
/#endif \/\* VIM__H \*\//i#undef LC_MESSAGES
/# include "auto\/osdef\.h"/ d
/#include "feature\.h"/ d
EOF

# sed -i '/#include "vim.h"/a#undef LC_MESSAGES' ex_cmds2.c

for file in $proto_remove; do
	sed -i "/$file/d" proto.h
done

sed -i '/EXTERN char_u\s*\*p_wig/iEXTERN char_u *p_wak;' option.h
sed -i '/gui_update_cursor/d' hangulin.c
vim -u NONE -E -s -c '%s/gui_redraw_block(\_.\{-});\n/\r/g' -c 'update' -c 'quit' hangulin.c || true

sed -i 's@^VIMPROG =.\+$@VIMPROG = ../../build/src/vim@' testdir/Makefile
sed -i 's@\.\./vim@../../build/src/vim@' testdir/test49.vim
sed -i 's@^VIM =.\+$@VIM = ../../build/src/vim@' po/Makefile
sed -i 's/\bDEBUG\b/REGEXP_DEBUG/g' regexp.c
sed -i 's/\bDEBUG\b/REGEXP_DEBUG/g' regexp_nfa.c

# fix some uncrustify errors
sed -i '248s/-   \./- 	./' quickfix.c
sed -i '2553s/> =/>=/' misc2.c
sed -i '4379s/> =/>=/' memline.c
sed -i '6897s/> =/>=/' spell.c
sed -i '4554s/> =/>=/' normal.c
sed -i -e '801s/> =/>=/' -e '940s/> =/>=/' ui.c


cat > "CMakeLists.txt" << "EOF"
file( GLOB NEOVIM_SOURCES *.c )

foreach(sfile ${NEOVIM_SOURCES})
  get_filename_component(f ${sfile} NAME)
  if(${f} MATCHES "^(regexp_nfa.c|farsi.c|arabic.c)$")
    list(APPEND to_remove ${sfile})
  endif()
endforeach()

list(REMOVE_ITEM NEOVIM_SOURCES ${to_remove})
list(APPEND NEOVIM_SOURCES "${PROJECT_BINARY_DIR}/config/auto/pathdef.c")

add_executable (vim ${NEOVIM_SOURCES}) 

target_link_libraries (vim m termcap selinux) 
include_directories ("${PROJECT_SOURCE_DIR}/src/proto") 
EOF

cd ..

cat > "CMakeLists.txt" << "EOF"
cmake_minimum_required (VERSION 2.6)
project (NEOVIM)

set(NEOVIM_VERSION_MAJOR 0)
set(NEOVIM_VERSION_MINOR 0)
set(NEOVIM_VERSION_PATCH 0)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# for now use gnu99, later we try to make this c99-compatible
add_definitions(-DHAVE_CONFIG_H -Wall -std=gnu99)
# add_definitions(-E -dD -dI -P)
if(CMAKE_BUILD_TYPE MATCHES Debug)
  # cmake automatically appends -g to the compiler flags
  set(DEBUG 1)
else()
  set(DEBUG 0)
endif()

# download and build dependencies
execute_process(COMMAND sh "${PROJECT_SOURCE_DIR}/scripts/get-deps.sh"
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

# add dependencies to include/lib directories
link_directories ("${PROJECT_SOURCE_DIR}/.deps/usr/lib")
include_directories ("${PROJECT_SOURCE_DIR}/.deps/usr/include") 

include_directories ("${PROJECT_BINARY_DIR}/config") 

add_subdirectory(src)
add_subdirectory(config)
EOF

mkdir -p config

cat > config/CMakeLists.txt << "EOF"
include(CheckTypeSize)
check_type_size("int" SIZEOF_INT)
check_type_size("long" SIZEOF_LONG)
check_type_size("time_t" SIZEOF_TIME_T)
check_type_size("off_t" SIZEOF_OFF_T)

# generate configuration header and update include directories
configure_file (
  "${PROJECT_SOURCE_DIR}/config/config.h.in"
  "${PROJECT_BINARY_DIR}/config/auto/config.h"
  )
# generate pathdef.c
set(USERNAME $ENV{USER})
set(HOSTNAME $ENV{HOST})
configure_file (
  "${PROJECT_SOURCE_DIR}/config/pathdef.c.in"
  "${PROJECT_BINARY_DIR}/config/auto/pathdef.c"
  ESCAPE_QUOTES)
EOF

cat > config/pathdef.c.in << "EOF"
#include "${PROJECT_SOURCE_DIR}/src/vim.h"
char_u *default_vim_dir = (char_u *)"${CMAKE_INSTALL_PREFIX}/share/vim";
char_u *default_vimruntime_dir = (char_u *)"";
char_u *all_cflags = (char_u *)"${CMAKE_C_FLAGS}";
char_u *all_lflags = (char_u *)"${CMAKE_SHARED_LINKER_FLAGS}";
char_u *compiled_user = (char_u *)"${USERNAME}";
char_u *compiled_sys = (char_u *)"${HOSTNAME}";
EOF

cat > "config/config.h.in" << "EOF"
#define NEOVIM_VERSION_MAJOR @NEOVIM_VERSION_MAJOR@
#define NEOVIM_VERSION_MINOR @NEOVIM_VERSION_MINOR@
#define NEOVIM_VERSION_PATCH @NEOVIM_VERSION_PATCH@

#if @DEBUG@
#define DEBUG
#endif

#define SIZEOF_INT @SIZEOF_INT@
#define SIZEOF_LONG @SIZEOF_LONG@
#define SIZEOF_TIME_T @SIZEOF_TIME_T@
#define SIZEOF_OFF_T @SIZEOF_OFF_T@

#define _FILE_OFFSET_BITS 64
#define HAVE_ATTRIBUTE_UNUSED 1
#define HAVE_BCMP 1
#define HAVE_BIND_TEXTDOMAIN_CODESET 1
#define HAVE_DATE_TIME 1
#define HAVE_DIRENT_H 1
#define HAVE_DLFCN_H 1
#define HAVE_DLOPEN 1
#define HAVE_DLSYM 1
#define HAVE_ERRNO_H 1
#define HAVE_FCHDIR 1
#define HAVE_FCHOWN 1
#define HAVE_FCNTL_H 1
#define HAVE_FD_CLOEXEC 1
#define HAVE_FLOAT_FUNCS 1
#define HAVE_FSEEKO 1
#define HAVE_FSYNC 1
#define HAVE_GETCWD 1
#define HAVE_GETPWENT 1
#define HAVE_GETPWNAM 1
#define HAVE_GETPWUID 1
#define HAVE_GETRLIMIT 1
#define HAVE_GETTEXT 1
#define HAVE_GETTIMEOFDAY 1
#define HAVE_GETWD 1
#define HAVE_ICONV 1
#define HAVE_ICONV_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_ISWUPPER 1
#define HAVE_LANGINFO_H 1
#define HAVE_LIBGEN_H 1
#define HAVE_LIBINTL_H 1
#define HAVE_LOCALE_H 1
#define HAVE_LSTAT 1
#define HAVE_MATH_H 1
#define HAVE_MEMCMP 1
#define HAVE_MEMSET 1
#define HAVE_MKDTEMP 1
#define HAVE_NANOSLEEP 1
#define HAVE_NL_LANGINFO_CODESET 1
#define HAVE_NL_MSG_CAT_CNTR 1
#define HAVE_OPENDIR 1
#define HAVE_OSPEED 1
#define HAVE_POLL_H 1
#define HAVE_PUTENV 1
#define HAVE_PWD_H 1
#define HAVE_QSORT 1
#define HAVE_READLINK 1
#define HAVE_RENAME 1
#define HAVE_SELECT 1
#define HAVE_SELINUX 1
#define HAVE_SETENV 1
#define HAVE_SETJMP_H 1
#define HAVE_SETPGID 1
#define HAVE_SETSID 1
#define HAVE_SGTTY_H 1
#define HAVE_SIGACTION 1
#define HAVE_SIGALTSTACK 1
#define HAVE_SIGCONTEXT 1
#define HAVE_SIGSTACK 1
#define HAVE_SIGVEC 1
#define HAVE_ST_BLKSIZE 1
#define HAVE_STDARG_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRCASECMP 1
#define HAVE_STRERROR 1
#define HAVE_STRFTIME 1
#define HAVE_STRING_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRNCASECMP 1
#define HAVE_STROPTS_H 1
#define HAVE_STRPBRK 1
#define HAVE_STRTOL 1
#define HAVE_SVR4_PTYS 1
#define HAVE_SYSCONF 1
#define HAVE_SYSINFO 1
#define HAVE_SYSINFO_MEM_UNIT 1
#define HAVE_SYS_IOCTL_H 1
#define HAVE_SYS_PARAM_H 1
#define HAVE_SYS_POLL_H 1
#define HAVE_SYS_RESOURCE_H 1
#define HAVE_SYS_SELECT_H 1
#define HAVE_SYS_STATFS_H 1
#define HAVE_SYS_SYSCTL_H 1
#define HAVE_SYS_SYSINFO_H 1
#define HAVE_SYS_TIME_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_UTSNAME_H 1
#define HAVE_SYS_WAIT_H 1
#define HAVE_TERMCAP_H 1
#define HAVE_TERMIO_H 1
#define HAVE_TERMIOS_H 1
#define HAVE_TGETENT 1
#define HAVE_TOWLOWER 1
#define HAVE_TOWUPPER 1
#define HAVE_UNISTD_H 1
#define HAVE_UP_BC_PC 1
#define HAVE_USLEEP 1
#define HAVE_UTIME 1
#define HAVE_UTIME_H 1
#define HAVE_UTIMES 1
#define HAVE_WCHAR_H 1
#define HAVE_WCTYPE_H 1
#define RETSIGTYPE void
#define SIGRETURN return
#define SYS_SELECT_WITH_SYS_TIME 1
#define TERMINFO 1
#define TGETENT_ZERO_ERR 0
#define TIME_WITH_SYS_TIME 1
#define UNIX 1
#define USEMAN_S 1
#define USEMEMMOVE 1

#define FEAT_ARABIC
#define FEAT_AUTOCHDIR
#define FEAT_AUTOCMD
#define FEAT_BROWSE
#define FEAT_BROWSE_CMD
#define FEAT_BYTEOFF
#define FEAT_CINDENT
#define FEAT_CMDHIST
#define FEAT_CMDL_COMPL
#define FEAT_CMDL_INFO
#define FEAT_CMDWIN
#define FEAT_COMMENTS
#define FEAT_COMPL_FUNC
#define FEAT_CONCEAL
#define FEAT_CON_DIALOG
#define FEAT_CRYPT
#define FEAT_CSCOPE
#define FEAT_CURSORBIND
#define FEAT_DIFF
#define FEAT_DIGRAPHS
#define FEAT_EVAL
#define FEAT_EX_EXTRA
#define FEAT_FIND_ID
#define FEAT_FKMAP
#define FEAT_FLOAT
#define FEAT_FOLDING
#define FEAT_GETTEXT
#define FEAT_HANGULIN
#define FEAT_INS_EXPAND
#define FEAT_JUMPLIST
#define FEAT_KEYMAP
#define FEAT_LANGMAP
#define FEAT_LINEBREAK
#define FEAT_LISP
#define FEAT_LISTCMDS
#define FEAT_LOCALMAP
#define FEAT_MBYTE
#define FEAT_MENU
#define FEAT_MODIFY_FNAME
#define FEAT_MOUSE
#define FEAT_MOUSE_DEC
#define FEAT_MOUSE_NET
#define FEAT_MOUSE_SGR
#define FEAT_MOUSE_TTY
#define FEAT_MOUSE_URXVT
#define FEAT_MOUSE_XTERM
#define FEAT_MULTI_LANG
#define FEAT_PATH_EXTRA
#define FEAT_PERSISTENT_UNDO
#define FEAT_POSTSCRIPT
#define FEAT_PRINTER
#define FEAT_PROFILE
#define FEAT_QUICKFIX
#define FEAT_RELTIME
#define FEAT_RIGHTLEFT
#define FEAT_SCROLLBIND
#define FEAT_SEARCHPATH
#define FEAT_SEARCH_EXTRA
#define FEAT_SESSION
#define FEAT_SMARTINDENT
#define FEAT_SPELL
#define FEAT_STL_OPT
#define FEAT_SYN_HL
#define FEAT_TAG_BINS
#define FEAT_TAG_OLDSTATIC
#define FEAT_TERMRESPONSE
#define FEAT_TEXTOBJ
#define FEAT_TITLE
#define FEAT_USR_CMDS
#define FEAT_VERTSPLIT
#define FEAT_VIMINFO
#define FEAT_VIRTUALEDIT
#define FEAT_VISUAL
#define FEAT_VISUALEXTRA
#define FEAT_VREPLACE
#define FEAT_WAK
#define FEAT_WILDIGN
#define FEAT_WILDMENU
#define FEAT_WINDOWS
#define FEAT_WRITEBACK
#define FEAT_HUGE
#define FEAT_BIG
#define FEAT_NORMAL
#define FEAT_SMALL
#define FEAT_TINY
#define FEAT_WRITEBACKUP
#define VIM_BACKTICK           /* internal backtick expansion */
EOF

mkdir -p scripts

cat > "scripts/build.sh" << "EOF"
#!/bin/sh -e

rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug ../
make
EOF

# cat > "scripts/env.sh" << "EOF"
# pkgroot="$(pwd)"
# deps="$pkgroot/.deps"
# prefix="$deps/usr"
# export PATH="$prefix/bin:$PATH"
# EOF

# cat > "scripts/get-deps.sh" << "EOF"
# #!/bin/sh -e
# download() {
# 	local url=$1
# 	local tgt=$2
# 	local sha1=$3

# 	if [ ! -d "$tgt" ]; then
# 		mkdir -p "$tgt"
# 		if which wget > /dev/null 2>&1; then
# 			tmp_dir=$(mktemp -d "/tmp/download_sha1check_XXXXXXX")
# 			fifo="$tmp_dir/fifo"
# 			mkfifo "$fifo"
# 			# download, untar and calculate sha1 sum in one pass
# 			(wget "$url" -O - | tee "$fifo" | \
# 				(cd "$tgt";  tar --strip-components=1 -xvzf -)) &
# 			sum=$(sha1sum < "$fifo" | cut -d ' ' -f1)
# 			rm -rf "$tmp_dir"
# 			if [ "$sum" != "$sha1" ]; then
# 				echo "SHA1 sum doesn't match, expected '$sha1' got '$sum'"
# 				exit 1
# 			fi
# 		else
# 			echo "Missing wget utility"
# 			exit 1
# 		fi
# 	fi
# }

# github_download() {
# 	local repo=$1
# 	local ver=$2
# 	download "https://github.com/${repo}/archive/${ver}.tar.gz" "$3" "$4"
# }

# . scripts/env.sh

# uv_repo=joyent/libuv
# uv_ver=v0.11.18
# uv_dir="$deps/uv-$uv_ver"
# uv_sha1=11ad2afbc8e6ab82ee15691b117e5736ef1d15e3

# if [ ! -e "$prefix/lib/libuv.a" ]; then
# 	github_download "$uv_repo" "$uv_ver" "$uv_dir" "$uv_sha1"
# 	(
# 	cd "$uv_dir"
# 	sh autogen.sh
# 	./configure --prefix="$prefix"
# 	make
# 	make install
# 	rm "$prefix/lib/"libuv*.so "$prefix/lib/"libuv*.so.*
# 	)
# fi
# EOF

# chmod +x scripts/build.sh
# chmod +x scripts/get-deps.sh

# cat > "src/types.h" << "EOF"
# #ifndef NEOVIM_TYPES_H
# #define NEOVIM_TYPES_H

# typedef unsigned char char_u;
# typedef unsigned short short_u;
# typedef unsigned int int_u;
# typedef void *vim_acl_T;

# #endif /* NEOVIM_TYPES_H */
# EOF

# cat > "src/util.h" << "EOF"
# #ifndef NEOVIM_UTIL_H
# #define NEOVIM_UTIL_H

# #define UNUSED(x) (void)(x)

# #endif /* NEOVIM_UTIL_H */
# EOF

# # Setup module which provides the os layer
# cat > "src/io.h" << "EOF"
# #ifndef NEOVIM_IO_H
# #define NEOVIM_IO_H

# #include "types.h"

# void io_init();
# char_u io_readbyte();

# #endif /* NEOVIM_IO_H */
# EOF

# cat > "src/io.c" << "EOF"
# #include <stdio.h>
# #include <string.h>
# #include <stdbool.h>
# #include <uv.h>

# #include "io.h"
# #include "util.h"

# #define BUF_SIZE 4096


# static uv_thread_t io_thread;
# static uv_mutex_t io_mutex;
# static uv_cond_t io_cond;
# static uv_async_t read_wake_async;
# static uv_fs_t current_fs_req;
# static uv_pipe_t stdin_pipe, stdout_pipe;
# static struct {
#   unsigned int wpos, rpos;
#   unsigned char data[BUF_SIZE];
# } in_buffer = {0, 0, 0};
# bool reading = false;


# /* Private */
# static void io_main(void *);
# static void loop_running(uv_idle_t *, int);
# static void read_wake(uv_async_t *, int);
# static void alloc_buffer_cb(uv_handle_t *, size_t, uv_buf_t *);
# static void read_cb(uv_stream_t *, ssize_t, const uv_buf_t *);
# static void io_lock();
# static void io_unlock();
# static void io_wait();
# static void io_signal();


# /* Called at startup to setup the background thread that will handle all
#  * events and translate to keys. */
# void io_init() {
#   uv_mutex_init(&io_mutex);
#   uv_cond_init(&io_cond);
#   io_lock();
#   /* The event loop runs in a background thread */
#   uv_thread_create(&io_thread, io_main, NULL);
#   /* Wait for the loop thread to be ready */
#   io_wait();
#   io_unlock();
# }


# char_u io_readbyte() {
#   char rv;

#   io_lock();
#   if (!reading) {
#     uv_async_send(&read_wake_async);
#     reading = true;
#   }

#   if (in_buffer.rpos == in_buffer.wpos)
#     io_wait();

#   rv = in_buffer.data[in_buffer.rpos++];
#   io_unlock();

#   return rv;
# }


# static void io_main(void *arg) {
#   uv_idle_t idler;

#   UNUSED(arg);
#   /* use default loop */
#   uv_loop_t *loop = uv_default_loop();
#   /* Idler for signaling the main thread when the loop is running */
#   uv_idle_init(loop, &idler);
#   uv_idle_start(&idler, loop_running);
#   /* Async watcher used by the main thread to resume reading */
#   uv_async_init(loop, &read_wake_async, read_wake);
#   /* stdin */
#   uv_pipe_init(loop, &stdin_pipe, 0);
#   uv_pipe_open(&stdin_pipe, 0);
#   /* stdout */
#   uv_pipe_init(loop, &stdout_pipe, 0);
#   uv_pipe_open(&stdout_pipe, 1);
#   /* start processing events */
#   uv_run(loop, UV_RUN_DEFAULT);
# }


# /* Signal the main thread that the loop started running */
# static void loop_running(uv_idle_t *handle, int status) {
#   uv_idle_stop(handle);
#   io_lock();
#   io_signal();
#   io_unlock();
# }


# /* Signal tell loop to continue reading stdin */
# static void read_wake(uv_async_t *handle, int status) {
#   UNUSED(handle);
#   UNUSED(status);
#   uv_read_start((uv_stream_t *)&stdin_pipe, alloc_buffer_cb, read_cb);
# }


# /* Called by libuv to allocate memory for reading. This uses a static buffer */
# static void alloc_buffer_cb(uv_handle_t *handle, size_t ssize, uv_buf_t *rv) {
#   int wpos;
#   UNUSED(handle);
#   io_lock();
#   wpos = in_buffer.wpos;
#   io_unlock();
#   if (wpos == BUF_SIZE) {
#     /* No more space in buffer */
#     rv->len = 0;
#     return;
#   }
#   if (BUF_SIZE < (wpos + ssize))
#     ssize = BUF_SIZE - wpos;
#   rv->base = in_buffer.data + wpos;
#   rv->len = ssize;
# }


# /* This is only used to check how many bytes were read or if an error
#  * occurred. If the static buffer is full(wpos == BUF_SIZE) try to move
#  * the data to free space, or stop reading. */
# static void read_cb(uv_stream_t *s, ssize_t cnt, const uv_buf_t *buf) {
#   int move_count;
#   UNUSED(s);
#   UNUSED(buf); /* Data is already on the static buffer */
#   if (cnt < 0) {
#     if (cnt == UV_EOF) {
#       uv_unref((uv_handle_t *)&stdin_pipe);
#     } else if (cnt == UV_ENOBUFS) {
#       /* Out of space in internal buffer, move data to the 'left' as much
#        * as possible. If we cant move anything, stop reading for now. */
#       io_lock();
#       if (in_buffer.rpos == 0)
#       {
#         reading = false;
#         io_unlock();
#         uv_read_stop((uv_stream_t *)&stdin_pipe);
#       }
#       move_count = BUF_SIZE - in_buffer.rpos;
#       memmove(in_buffer.data, in_buffer.data + in_buffer.rpos, move_count);
#       in_buffer.wpos -= in_buffer.rpos;
#       in_buffer.rpos = 0;
#       io_unlock();
#     }
#     else {
#       fprintf(stderr, "Unexpected error %s\n", uv_strerror(cnt));
#     }
#     return;
#   }
#   io_lock();
#   in_buffer.wpos += cnt;
#   io_signal();
#   io_unlock();
# }


# /* Helpers for dealing with io synchronization */
# static void io_lock() {
#   uv_mutex_lock(&io_mutex);
# }


# static void io_unlock() {
#   uv_mutex_unlock(&io_mutex);
# }


# static void io_wait() {
#   uv_cond_wait(&io_cond, &io_mutex);
# }


# static void io_signal() {
#   uv_cond_signal(&io_cond);
# }
# EOF
