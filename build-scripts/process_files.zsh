#!/bin/zsh -e

# Refactor:
# vim_tempname(fileio.c)
cpp=/tmp/vim-cpp.py

# if [[ ! -e $cpp ]]; then
cat > $cpp << "EOF"
#!/usr/bin/env python

from __future__ import generators
import json
class IgnoreException(BaseException):
    pass
def ignorer(): raise IgnoreException()
COLLECTED = None

IGNORE = [
    'ALIGN_LONG', 
    'BINARY_FILE_IO', 
    'BREAKCHECK_SKIP', 
    'BT_REGEXP_DEBUG_LOG', 
    'BT_REGEXP_DUMP', 
    'BT_REGEXP_LOG', 
    'B_IMODE_IM', 
    'CASE_INSENSITIVE_FILENAME', 
    'CHECK_DOUBLE_CLICK', 
    'CHECK_INODE', 
    'CMDBUFFSIZE', 
    'CP_UTF8', 
    'CREATE_DUMMY_FILE', 
    'DEBUG', 
    'DEBUG_TERMRESPONSE', 
    'DEBUG_TRIEWALK', 
    'DEFAULT_TERM', 
    'DFLT_BDIR', 
    'DFLT_DIR', 
    'DFLT_HELPFILE', 
    'DFLT_MAXMEM', 
    'DFLT_MAXMEMTOT', 
    'DFLT_VDIR', 
    'DO_DECLARE_EXCMD', 
    'DO_INIT', 
    'ECHILD', 
    'EEXIST', 
    'EILSEQ', 
    'EINTR', 
    'ENABLE_LOG', 
    'ENOENT', 
    'EVIM_FILE', 
    'EX', 
    'EXRC_FILE', 
    'EXTERN', 
    'FILETYPE_FILE', 
    'FTOFF_FILE', 
    'FTPLUGIN_FILE', 
    'FTPLUGOF_FILE', 
    'GVIMRC_FILE', 
    'HANGUL_DEFAULT_KEYBOARD', 
    'HAS_BW_FLAGS', 
    'HAS_SWAP_EXISTS_ACTION', 
    'HAVE_ACL', 
    'HAVE_ATTRIBUTE_UNUSED',
    'HAVE_BCMP',
    'HAVE_BIND_TEXTDOMAIN_CODESET', 
    'HAVE_BUFLIST_MATCH', 
    'HAVE_CHECK_STACK_GROWTH', 
    'HAVE_CONFIG_H', 
    'HAVE_DATE_TIME',
    'HAVE_DIRENT_H',
    'HAVE_DLFCN_H',
    'HAVE_DLOPEN',
    'HAVE_DLSYM',
    'HAVE_DUP', 
    'HAVE_ERRNO_H',
    'HAVE_EX_SCRIPT_NI', 
    'HAVE_FCHDIR',
    'HAVE_FCHOWN',
    'HAVE_FCNTL_H',
    'HAVE_FD_CLOEXEC',
    'HAVE_FLOAT_FUNCS',
    'HAVE_FSEEKO',
    'HAVE_FSYNC',
    'HAVE_GETCWD',
    'HAVE_GETPWENT',
    'HAVE_GETPWNAM',
    'HAVE_GETPWUID',
    'HAVE_GETRLIMIT',
    'HAVE_GETTEXT',
    'HAVE_GETTIMEOFDAY',
    'HAVE_GETWD',
    'HAVE_GET_LOCALE_VAL', 
    'HAVE_ICONV',
    'HAVE_ICONV_H',
    'HAVE_INTTYPES_H',
    'HAVE_ISWUPPER',
    'HAVE_LANGINFO_H',
    'HAVE_LIBGEN_H',
    'HAVE_LIBINTL_H',
    'HAVE_LOCALE_H',
    'HAVE_LSTAT',
    'HAVE_MATH_H',
    'HAVE_MEMCMP',
    'HAVE_MEMSET',
    'HAVE_MKDTEMP',
    'HAVE_NANOSLEEP',
    'HAVE_NL_LANGINFO_CODESET',
    'HAVE_NL_MSG_CAT_CNTR',
    'HAVE_OPENDIR',
    'HAVE_OSPEED',
    'HAVE_PATHDEF', 
    'HAVE_POLL_H',
    'HAVE_PUTENV',
    'HAVE_PWD_H',
    'HAVE_QSORT',
    'HAVE_READLINK',
    'HAVE_RENAME',
    'HAVE_SANDBOX', 
    'HAVE_SELECT',
    'HAVE_SELINUX',
    'HAVE_SETENV',
    'HAVE_SETENV', 
    'HAVE_SETJMP_H',
    'HAVE_SETPGID',
    'HAVE_SETSID',
    'HAVE_SGTTY_H',
    'HAVE_SIGACTION',
    'HAVE_SIGALTSTACK',
    'HAVE_SIGCONTEXT',
    'HAVE_SIGSET',
    'HAVE_SIGSTACK',
    'HAVE_SIGVEC',
    'HAVE_STDARG_H',
    'HAVE_STDINT_H',
    'HAVE_STDLIB_H',
    'HAVE_STRCASECMP',
    'HAVE_STRERROR',
    'HAVE_STRFTIME',
    'HAVE_STRINGS_H',
    'HAVE_STRING_H',
    'HAVE_STRNCASECMP',
    'HAVE_STROPTS_H',
    'HAVE_STRPBRK',
    'HAVE_STRTOL',
    'HAVE_ST_BLKSIZE',
    'HAVE_ST_MODE', 
    'HAVE_SVR4_PTYS',
    'HAVE_SYSCONF',
    'HAVE_SYSINFO',
    'HAVE_SYSINFO_MEM_UNIT',
    'HAVE_SYS_IOCTL_H',
    'HAVE_SYS_PARAM_H',
    'HAVE_SYS_POLL_H',
    'HAVE_SYS_RESOURCE_H',
    'HAVE_SYS_SELECT_H',
    'HAVE_SYS_STATFS_H',
    'HAVE_SYS_SYSCTL_H',
    'HAVE_SYS_SYSINFO_H',
    'HAVE_SYS_TIME_H',
    'HAVE_SYS_TYPES_H',
    'HAVE_SYS_UTSNAME_H',
    'HAVE_SYS_WAIT_H',
    'HAVE_TERMCAP_H',
    'HAVE_TERMIOS_H',
    'HAVE_TERMIO_H',
    'HAVE_TGETENT',
    'HAVE_TOTAL_MEM', 
    'HAVE_TOWLOWER',
    'HAVE_TOWUPPER',
    'HAVE_UNISTD_H',
    'HAVE_UP_BC_PC',
    'HAVE_USLEEP',
    'HAVE_UTIME',
    'HAVE_UTIMES',
    'HAVE_UTIME_H',
    'HAVE_WCHAR_H',
    'HAVE_WCTYPE_H',
    'HT_DEBUG', 
    'INDENT_FILE', 
    'INDOFF_FILE', 
    'INIT', 
    'IN_OPTION_C', 
    'LEN_FROM_CONV', 
    'LINE_ATTR', 
    'LONG_LONG_OFF_T', 
    'MAXNAMLEN', 
    'MAXPATHL', 
    'MAY_LOOP', 
    'MESSAGE_FILE', 
    'MIN', 
    'MKSESSION_NL', 
    'MSWIN', 
    'NAMLEN', 
    'NFA_REGEXP_DEBUG_LOG', 
    'NFA_REGEXP_ERROR_LOG', 
    'NOPROTO', 
    'NO_EXPANDPATH', 
    'OK', 
    'ONE_CLIPBOARD', 
    'OPEN_CHR_FILES', 
    'O_NOCTTY', 
    'O_NOFOLLOW', 
    'O_NONBLOCK', 
    'POUND', 
    'PTYRANGE0', 
    'PTYRANGE1', 
    'PTY_DONE', 
    'RANGE', 
    'RETSIGTYPE',
    'R_OK', 
    'SEEK_END', 
    'SEEK_SET', 
    'SET_SIG_ALARM', 
    'SIGABRT',
    'SIGALRM',
    'SIGBUS',
    'SIGFPE',
    'SIGHAS3ARGS', 
    'SIGHASARG', 
    'SIGHUP',
    'SIGILL',
    'SIGINT',
    'SIGPIPE',
    'SIGPWR',
    'SIGQUIT',
    'SIGRETURN',
    'SIGSEGV',
    'SIGSTKSZ', 
    'SIGSTP',
    'SIGSYS',
    'SIGTERM',
    'SIGTRAP',
    'SIGTSTP',
    'SIGUSR1',
    'SIGUSR2',
    'SIGWINCH', 
    'SIG_ERR', 
    'SIZEOF_INT', 
    'SIZEOF_LONG', 
    'SIZEOF_OFF_T', 
    'SMALL_MALLOC', 
    'SMALL_MEM', 
    'SPECIAL_WILDCHAR', 
    'SPELL_PRINTTREE', 
    'STATFS', 
    'SYNTAX_FNAME', 
    'SYS_GVIMRC_FILE', 
    'SYS_MENU_FILE', 
    'SYS_NMLN', 
    'SYS_SELECT_WITH_SYS_TIME',
    'SYS_VIMRC_FILE', 
    'S_ISBLK',
    'S_ISCHR',
    'S_ISDIR',
    'S_ISFIFO',
    'S_ISREG',
    'S_ISSOCK',
    'TEMPDIRNAMES', 
    'TERMINFO',
    'TGETENT_ZERO_ERR',
    'THROW_ON_ERROR_TRUE', 
    'THROW_ON_INTERRUPT_TRUE', 
    'THROW_TEST', 
    'TIME_WITH_SYS_TIME',
    'TIOCSETN', 
    'TTYM_SGR', 
    'UINT32_TYPEDEF', 
    'UNIX', 
    'USEMAN_S',
    'USEMEMMOVE',
    'USER_HIGHLIGHT', 
    'USE_FILE_CHOOSER', 
    'USE_FNAME_CASE', 
    'USE_FOPEN_NOINH', 
    'USE_FSTATFS', 
    'USE_GETCWD', 
    'USE_IM_CONTROL', 
    'USE_INPUT_BUF', 
    'USE_MCH_ACCESS', 
    'USE_MCH_ERRMSG', 
    'USE_START_TV', 
    'USE_UNICODE_DIGRAPHS', 
    'USE_UTF8_STRING', 
    'USE_WCHAR_FUNCTIONS', 
    'USE_X11R6_XIM', 
    'USE_XSMP_INTERACT',
    'USR_EXRC_FILE', 
    'USR_EXRC_FILE2', 
    'USR_GVIMRC_FILE', 
    'USR_GVIMRC_FILE2', 
    'USR_GVIMRC_FILE3', 
    'USR_VIMRC_FILE', 
    'USR_VIMRC_FILE2', 
    'USR_VIMRC_FILE3', 
    'VIMINFO_FILE', 
    'VIMINFO_FILE2', 
    'VIMPACKAGE', 
    'VIMRC_FILE', 
    'VIM_MEMCMP', 
    'VIM_MEMMOVE', 
    'VIM__H', 
    'VMS_TEMPNAM', 
    'WEXITSTATUS', 
    'WIFEXITED', 
    'W_OK', 
    '_', 
    '_FILE_OFFSET_BITS',
    '_IO_PTEM_H', 
    '_NO_PROTO', 
    '_REGEXP_H', 
    '_TANDEM_SOURCE', 
    '__PARMS', 
    'bind_textdomain_codeset', 
    'bindtextdomain', 
    'mblen', 
    'mch_errmsg', 
    'mch_memmove', 
    'mch_msg', 
    'signal', 
    'textdomain', 
    'vim_mkdir', 
    'vim_strpbrk'
]

KEEP = {
    'ALL_BUILTIN_TCAPS': 1,
    'CURSOR_SHAPE': 1,
    'ECHOE': 1,
    'ESC_CHG_TO_ENG_MODE': 1,
    'FALSE': 'false',
    'FEAT_ARABIC': 1,
    'FEAT_AUTOCHDIR': 1,
    'FEAT_AUTOCMD': 1,
    'FEAT_BROWSE_CMD': 1,
    'FEAT_BYTEOFF': 1,
    'FEAT_CINDENT': 1,
    'FEAT_CMDHIST': 1,
    'FEAT_CMDL_COMPL': 1,
    'FEAT_CMDL_INFO': 1,
    'FEAT_CMDWIN': 1,
    'FEAT_COMMENTS': 1,
    'FEAT_COMPL_FUNC': 1,
    'FEAT_CONCEAL': 1,
    'FEAT_CON_DIALOG': 1,
    'FEAT_CRYPT': 1,
    'FEAT_CSCOPE': 1,
    'FEAT_CURSORBIND': 1,
    'FEAT_DIFF': 1,
    'FEAT_DIGRAPHS': 1,
    'FEAT_EVAL': 1,
    'FEAT_EX_EXTRA': 1,
    'FEAT_FIND_ID': 1,
    'FEAT_FKMAP': 1,
    'FEAT_FLOAT': 1,
    'FEAT_FOLDING': 1,
    'FEAT_GETTEXT': 1,
    'FEAT_HANGULIN': 1,
    'FEAT_HUGE': 1,
    'FEAT_INS_EXPAND': 1,
    'FEAT_JUMPLIST': 1,
    'FEAT_KEYMAP': 1,
    'FEAT_LANGMAP': 1,
    'FEAT_LINEBREAK': 1,
    'FEAT_LISP': 1,
    'FEAT_LISTCMDS': 1,
    'FEAT_LOCALMAP': 1,
    'FEAT_MBYTE': 1,
    'FEAT_MENU': 1,
    'FEAT_MODIFY_FNAME': 1,
    'FEAT_MOUSE': 1,
    'FEAT_MOUSE_DEC': 1,
    'FEAT_MOUSE_NET': 1,
    'FEAT_MOUSE_SGR': 1,
    'FEAT_MOUSE_TTY': 1,
    'FEAT_MOUSE_URXVT': 1,
    'FEAT_MOUSE_XTERM': 1,
    'FEAT_MULTI_LANG': 1,
    'FEAT_PATH_EXTRA': 1,
    'FEAT_PERSISTENT_UNDO': 1,
    'FEAT_POSTSCRIPT': 1,
    'FEAT_PRINTER': 1,
    'FEAT_PROFILE': 1,
    'FEAT_QUICKFIX': 1,
    'FEAT_RELTIME': 1,
    'FEAT_RIGHTLEFT': 1,
    'FEAT_SCROLLBIND': 1,
    'FEAT_SEARCHPATH': 1,
    'FEAT_SEARCH_EXTRA': 1,
    'FEAT_SESSION': 1,
    'FEAT_SIGNS': 1,
    'FEAT_SMARTINDENT': 1,
    'FEAT_SPELL': 1,
    'FEAT_STL_OPT': 1,
    'FEAT_SYN_HL': 1,
    'FEAT_TAG_BINS': 1,
    'FEAT_TAG_OLDSTATIC': 1,
    'FEAT_TERMRESPONSE': 1,
    'FEAT_TEXTOBJ': 1,
    'FEAT_TITLE': 1,
    'FEAT_USR_CMDS': 1,
    'FEAT_VERTSPLIT': 1,
    'FEAT_VIMINFO': 1,
    'FEAT_VIRTUALEDIT': 1,
    'FEAT_VISUAL': 1,
    'FEAT_VISUALEXTRA': 1,
    'FEAT_VREPLACE': 1,
    'FEAT_WAK': 1,
    'FEAT_WILDIGN': 1,
    'FEAT_WILDMENU': 1,
    'FEAT_WINDOWS': 1,
    'FEAT_WRITEBACKUP': 1,
    'ICANON': 1,
    'STARTUPTIME': 1,
    'TRUE': 'true',
    'UNIX': 1,
    'USE_ICONV': 1,
    'VIM_BACKTICK': 1
}
# -----------------------------------------------------------------------------
# cpp.py
#
# Author:  David Beazley (http://www.dabeaz.com)
# Copyright (C) 2007
# All rights reserved
#
# This module implements an ANSI-C style lexical preprocessor for PLY. 
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Default preprocessor lexer definitions.   These tokens are enough to get
# a basic preprocessor working.   Other modules may import these if they want
# -----------------------------------------------------------------------------

tokens = (
   'CPP_ID','CPP_INTEGER', 'CPP_FLOAT', 'CPP_STRING', 'CPP_CHAR', 'CPP_WS', 'CPP_COMMENT', 'CPP_POUND','CPP_DPOUND'
)

literals = "+-*/%|&~^<>=!?()[]{}.,;:\\\'\""

# Whitespace
def t_CPP_WS(t):
    r'\s+'
    t.lexer.lineno += t.value.count("\n")
    return t

t_CPP_POUND = r'\#'
t_CPP_DPOUND = r'\#\#'

# Identifier
t_CPP_ID = r'[A-Za-z_][\w_]*'

# Integer literal
def CPP_INTEGER(t):
    r'(((((0x)|(0X))[0-9a-fA-F]+)|(\d+))([uU]|[lL]|[uU][lL]|[lL][uU])?)'
    return t

t_CPP_INTEGER = CPP_INTEGER

# Floating literal
t_CPP_FLOAT = r'((\d+)(\.\d+)(e(\+|-)?(\d+))? | (\d+)e(\+|-)?(\d+))([lL]|[fF])?'

# String literal
def t_CPP_STRING(t):
    r'\"([^\\\n]|(\\(.|\n)))*?\"'
    t.lexer.lineno += t.value.count("\n")
    return t

# Character constant 'c' or L'c'
def t_CPP_CHAR(t):
    r'(L)?\'([^\\\n]|(\\(.|\n)))*?\''
    t.lexer.lineno += t.value.count("\n")
    return t

# Comment
def t_CPP_COMMENT(t):
    r'(/\*(.|\n)*?\*/)|(//.*?\n)'
    t.lexer.lineno += t.value.count("\n")
    return t
    
def t_error(t):
    t.type = t.value[0]
    t.value = t.value[0]
    t.lexer.skip(1)
    return t

import re
import copy
import time
import os.path
import ply.lex as lex

# -----------------------------------------------------------------------------
# trigraph()
# 
# Given an input string, this function replaces all trigraph sequences. 
# The following mapping is used:
#
#     ??=    #
#     ??/    \
#     ??'    ^
#     ??(    [
#     ??)    ]
#     ??!    |
#     ??<    {
#     ??>    }
#     ??-    ~
# -----------------------------------------------------------------------------

_trigraph_pat = re.compile(r'''\?\?[=/\'\(\)\!<>\-]''')
_trigraph_rep = {
    '=':'#',
    '/':'\\',
    "'":'^',
    '(':'[',
    ')':']',
    '!':'|',
    '<':'{',
    '>':'}',
    '-':'~'
}

def trigraph(input):
    return _trigraph_pat.sub(lambda g: _trigraph_rep[g.group()[-1]],input)

# ------------------------------------------------------------------
# Macro object
#
# This object holds information about preprocessor macros
#
#    .name      - Macro name (string)
#    .value     - Macro value (a list of tokens)
#    .arglist   - List of argument names
#    .variadic  - Boolean indicating whether or not variadic macro
#    .vararg    - Name of the variadic parameter
#
# When a macro is created, the macro replacement token sequence is
# pre-scanned and used to create patch lists that are later used
# during macro expansion
# ------------------------------------------------------------------

class Macro(object):
    def __init__(self,name,value,arglist=None,variadic=False):
        self.name = name
        self.value = value
        self.arglist = arglist
        self.variadic = variadic
        if variadic:
            self.vararg = arglist[-1]
        self.source = None

# ------------------------------------------------------------------
# Preprocessor object
#
# Object representing a preprocessor.  Contains macro definitions,
# include directories, and other information
# ------------------------------------------------------------------

class Preprocessor(object):
    def __init__(self,lexer=None):
        if lexer is None:
            lexer = lex.lexer
        self.lexer = lexer
        self.path = []
        self.temp_path = []

        # Probe the lexer for selected tokens
        self.lexprobe()
        self.macros = { }
        for k, v in KEEP.iteritems():
            t = lex.LexToken()
            t.type = self.t_INTEGER;
            t.value = str(v)
            self.macros[k] = Macro(k, [t])

        self.define("__ARGS(x) x")
        self.parser = None

    # -----------------------------------------------------------------------------
    # tokenize()
    #
    # Utility function. Given a string of text, tokenize into a list of tokens
    # -----------------------------------------------------------------------------

    def tokenize(self,text):
        tokens = []
        self.lexer.input(text)
        while True:
            tok = self.lexer.token()
            if not tok: break
            tokens.append(tok)
        return tokens

    # ---------------------------------------------------------------------
    # error()
    #
    # Report a preprocessor error/warning of some kind
    # ----------------------------------------------------------------------

    def error(self,file,line,msg):
        print >>sys.stderr,"%s:%d %s" % (file,line,msg)

    # ----------------------------------------------------------------------
    # lexprobe()
    #
    # This method probes the preprocessor lexer object to discover
    # the token types of symbols that are important to the preprocessor.
    # If this works right, the preprocessor will simply "work"
    # with any suitable lexer regardless of how tokens have been named.
    # ----------------------------------------------------------------------

    def lexprobe(self):

        # Determine the token type for identifiers
        self.lexer.input("identifier")
        tok = self.lexer.token()
        if not tok or tok.value != "identifier":
            print "Couldn't determine identifier type"
        else:
            self.t_ID = tok.type

        # Determine the token type for integers
        self.lexer.input("12345")
        tok = self.lexer.token()
        if not tok or int(tok.value) != 12345:
            print "Couldn't determine integer type"
        else:
            self.t_INTEGER = tok.type
            self.t_INTEGER_TYPE = type(tok.value)

        # Determine the token type for strings enclosed in double quotes
        self.lexer.input("\"filename\"")
        tok = self.lexer.token()
        if not tok or tok.value != "\"filename\"":
            print "Couldn't determine string type"
        else:
            self.t_STRING = tok.type

        # Determine the token type for whitespace--if any
        self.lexer.input("  ")
        tok = self.lexer.token()
        if not tok or tok.value != "  ":
            self.t_SPACE = None
        else:
            self.t_SPACE = tok.type

        # Determine the token type for newlines
        self.lexer.input("\n")
        tok = self.lexer.token()
        if not tok or tok.value != "\n":
            self.t_NEWLINE = None
            print "Couldn't determine token for newlines"
        else:
            self.t_NEWLINE = tok.type

        self.t_WS = (self.t_SPACE, self.t_NEWLINE)

        # Check for other characters used by the preprocessor
        chars = [ '<','>','#','##','\\','(',')',',','.']
        for c in chars:
            self.lexer.input(c)
            tok = self.lexer.token()
            if not tok or tok.value != c:
                print "Unable to lex '%s' required for preprocessor" % c

    # ----------------------------------------------------------------------
    # add_path()
    #
    # Adds a search path to the preprocessor.  
    # ----------------------------------------------------------------------

    def add_path(self,path):
        self.path.append(path)

    # ----------------------------------------------------------------------
    # group_lines()
    #
    # Given an input string, this function splits it into lines.  Trailing whitespace
    # is removed.   Any line ending with \ is grouped with the next line.  This
    # function forms the lowest level of the preprocessor---grouping into text into
    # a line-by-line format.
    # ----------------------------------------------------------------------

    def group_lines(self,input):
        lex = self.lexer.clone()
        lines = [x.rstrip() for x in input.splitlines()]
        for i in xrange(len(lines)):
            j = i+1
            while lines[i].endswith('\\') and (j < len(lines)):
                lines[i] = lines[i][:-1]+lines[j]
                lines[j] = ""
                j += 1

        input = "\n".join(lines)
        lex.input(input)
        lex.lineno = 1

        current_line = []
        while True:
            tok = lex.token()
            if not tok:
                break
            current_line.append(tok)
            if tok.type in self.t_WS and '\n' in tok.value:
                yield current_line
                current_line = []

        if current_line:
            yield current_line

    # ----------------------------------------------------------------------
    # tokenstrip()
    # 
    # Remove leading/trailing whitespace tokens from a token list
    # ----------------------------------------------------------------------

    def tokenstrip(self,tokens):
        i = 0
        while i < len(tokens) and tokens[i].type in self.t_WS:
            i += 1
        del tokens[:i]
        i = len(tokens)-1
        while i >= 0 and tokens[i].type in self.t_WS:
            i -= 1
        del tokens[i+1:]
        return tokens


    # ----------------------------------------------------------------------
    # collect_args()
    #
    # Collects comma separated arguments from a list of tokens.   The arguments
    # must be enclosed in parenthesis.  Returns a tuple (tokencount,args,positions)
    # where tokencount is the number of tokens consumed, args is a list of arguments,
    # and positions is a list of integers containing the starting index of each
    # argument.  Each argument is represented by a list of tokens.
    #
    # When collecting arguments, leading and trailing whitespace is removed
    # from each argument.  
    #
    # This function properly handles nested parenthesis and commas---these do not
    # define new arguments.
    # ----------------------------------------------------------------------

    def collect_args(self,tokenlist):
        args = []
        positions = []
        current_arg = []
        nesting = 1
        tokenlen = len(tokenlist)
    
        # Search for the opening '('.
        i = 0
        while (i < tokenlen) and (tokenlist[i].type in self.t_WS):
            i += 1

        if (i < tokenlen) and (tokenlist[i].value == '('):
            positions.append(i+1)
        else:
            self.error(self.source,tokenlist[0].lineno,"Missing '(' in macro arguments")
            return 0, [], []

        i += 1

        while i < tokenlen:
            t = tokenlist[i]
            if t.value == '(':
                current_arg.append(t)
                nesting += 1
            elif t.value == ')':
                nesting -= 1
                if nesting == 0:
                    if current_arg:
                        args.append(self.tokenstrip(current_arg))
                        positions.append(i)
                    return i+1,args,positions
                current_arg.append(t)
            elif t.value == ',' and nesting == 1:
                args.append(self.tokenstrip(current_arg))
                positions.append(i+1)
                current_arg = []
            else:
                current_arg.append(t)
            i += 1
    
        # Missing end argument
        self.error(self.source,tokenlist[-1].lineno,"Missing ')' in macro arguments")
        return 0, [],[]

    # ----------------------------------------------------------------------
    # macro_prescan()
    #
    # Examine the macro value (token sequence) and identify patch points
    # This is used to speed up macro expansion later on---we'll know
    # right away where to apply patches to the value to form the expansion
    # ----------------------------------------------------------------------
    
    def macro_prescan(self,macro):
        macro.patch     = []             # Standard macro arguments 
        macro.str_patch = []             # String conversion expansion
        macro.var_comma_patch = []       # Variadic macro comma patch
        i = 0
        while i < len(macro.value):
            if macro.value[i].type == self.t_ID and macro.value[i].value in macro.arglist:
                argnum = macro.arglist.index(macro.value[i].value)
                # Conversion of argument to a string
                if i > 0 and macro.value[i-1].value == '#':
                    macro.value[i] = copy.copy(macro.value[i])
                    macro.value[i].type = self.t_STRING
                    del macro.value[i-1]
                    macro.str_patch.append((argnum,i-1))
                    continue
                # Concatenation
                elif (i > 0 and macro.value[i-1].value == '##'):
                    macro.patch.append(('c',argnum,i-1))
                    del macro.value[i-1]
                    continue
                elif ((i+1) < len(macro.value) and macro.value[i+1].value == '##'):
                    macro.patch.append(('c',argnum,i))
                    i += 1
                    continue
                # Standard expansion
                else:
                    macro.patch.append(('e',argnum,i))
            elif macro.value[i].value == '##':
                if macro.variadic and (i > 0) and (macro.value[i-1].value == ',') and \
                        ((i+1) < len(macro.value)) and (macro.value[i+1].type == self.t_ID) and \
                        (macro.value[i+1].value == macro.vararg):
                    macro.var_comma_patch.append(i-1)
            i += 1
        macro.patch.sort(key=lambda x: x[2],reverse=True)

    # ----------------------------------------------------------------------
    # macro_expand_args()
    #
    # Given a Macro and list of arguments (each a token list), this method
    # returns an expanded version of a macro.  The return value is a token sequence
    # representing the replacement macro tokens
    # ----------------------------------------------------------------------

    def macro_expand_args(self,macro,args):
        # Make a copy of the macro token sequence
        rep = [copy.copy(_x) for _x in macro.value]

        # Make string expansion patches.  These do not alter the length of the replacement sequence
        
        str_expansion = {}
        for argnum, i in macro.str_patch:
            if argnum not in str_expansion:
                str_expansion[argnum] = ('"%s"' % "".join([x.value for x in args[argnum]])).replace("\\","\\\\")
            rep[i] = copy.copy(rep[i])
            rep[i].value = str_expansion[argnum]

        # Make the variadic macro comma patch.  If the variadic macro argument is empty, we get rid
        comma_patch = False
        if macro.variadic and not args[-1]:
            for i in macro.var_comma_patch:
                rep[i] = None
                comma_patch = True

        # Make all other patches.   The order of these matters.  It is assumed that the patch list
        # has been sorted in reverse order of patch location since replacements will cause the
        # size of the replacement sequence to expand from the patch point.
        
        expanded = { }
        for ptype, argnum, i in macro.patch:
            # Concatenation.   Argument is left unexpanded
            if ptype == 'c':
                rep[i:i+1] = args[argnum]
            # Normal expansion.  Argument is macro expanded first
            elif ptype == 'e':
                if argnum not in expanded:
                    expanded[argnum] = self.expand_macros(args[argnum])
                rep[i:i+1] = expanded[argnum]

        # Get rid of removed comma if necessary
        if comma_patch:
            rep = [_i for _i in rep if _i]

        return rep


    # ----------------------------------------------------------------------
    # expand_macros()
    #
    # Given a list of tokens, this function performs macro expansion.
    # The expanded argument is a dictionary that contains macros already
    # expanded.  This is used to prevent infinite recursion.
    # ----------------------------------------------------------------------

    def expand_macros(self,tokens,expanded=None):
        if expanded is None:
            expanded = {}
        i = 0
        while i < len(tokens):
            t = tokens[i]
            if t.type == self.t_ID:
                if t.value in self.macros and t.value not in expanded:
                    # Yes, we found a macro match
                    expanded[t.value] = True
                    if t.value not in ['__ARGS', 'TRUE', 'FALSE']: continue
                    
                    m = self.macros[t.value]
                    if not m.arglist:
                        # A simple macro
                        ex = self.expand_macros([copy.copy(_x) for _x in m.value],expanded)
                        for e in ex:
                            e.lineno = t.lineno
                        tokens[i:i+1] = ex
                        i += len(ex)
                    else:
                        # A macro with arguments
                        j = i + 1
                        while j < len(tokens) and tokens[j].type in self.t_WS:
                            j += 1
                        if tokens[j].value == '(':
                            tokcount,args,positions = self.collect_args(tokens[j:])
                            if not m.variadic and len(args) !=  len(m.arglist):
                                self.error(self.source,t.lineno,"Macro %s requires %d arguments" % (t.value,len(m.arglist)))
                                i = j + tokcount
                            elif m.variadic and len(args) < len(m.arglist)-1:
                                if len(m.arglist) > 2:
                                    self.error(self.source,t.lineno,"Macro %s must have at least %d arguments" % (t.value, len(m.arglist)-1))
                                else:
                                    self.error(self.source,t.lineno,"Macro %s must have at least %d argument" % (t.value, len(m.arglist)-1))
                                i = j + tokcount
                            else:
                                if m.variadic:
                                    if len(args) == len(m.arglist)-1:
                                        args.append([])
                                    else:
                                        args[len(m.arglist)-1] = tokens[j+positions[len(m.arglist)-1]:j+tokcount-1]
                                        del args[len(m.arglist):]
                                        
                                # Get macro replacement text
                                rep = self.macro_expand_args(m,args)
                                rep = self.expand_macros(rep,expanded)
                                for r in rep:
                                    r.lineno = t.lineno
                                tokens[i:j+tokcount] = rep
                                i += len(rep)
                    del expanded[t.value]
                    continue
                elif t.value == '__LINE__':
                    t.type = self.t_INTEGER
                    t.value = self.t_INTEGER_TYPE(t.lineno)
                
            i += 1
        return tokens

    # ----------------------------------------------------------------------    
    # evalexpr()
    # 
    # Evaluate an expression token sequence for the purposes of evaluating
    # integral expressions.
    # ----------------------------------------------------------------------

    def evalexpr(self,tokens):
        # tokens = tokenize(line)
        # Search for defined macros
        tokens = copy.copy(tokens)
        i = 0
        ignoring = False
        orig = "".join([x.value for x in tokens])
        while i < len(tokens):
            if tokens[i].type == self.t_ID and tokens[i].value == 'defined':
                j = i + 1
                needparen = False
                result = "0L"
                while j < len(tokens):
                    if tokens[j].type in self.t_WS:
                        j += 1
                        continue
                    elif tokens[j].type == self.t_ID:
                        if COLLECTED: COLLECTED['tested'][tokens[j].value] = 1
                        if tokens[j].value in IGNORE:
                            result = 'IGNORE'
                            break
                        elif tokens[j].value in self.macros:
                            result = "1L"
                        else:
                            result = "0L"
                        if not needparen: break
                    elif tokens[j].value == '(':
                        needparen = True
                    elif tokens[j].value == ')':
                        break
                    else:
                        self.error(self.source,tokens[i].lineno,"Malformed defined()")
                    j += 1
                tokens[i] = copy.copy(tokens[i])
                if result == 'IGNORE':
                    tokens[i].type = 'IGNORE'
                else: 
                    tokens[i].type = self.t_INTEGER
                    tokens[i].value = self.t_INTEGER_TYPE(result)
                    del tokens[i+1:j+1]
            i += 1
        tokens = self.expand_macros(tokens)
        for i,t in enumerate(tokens):
            if t.type == self.t_ID:
                tokens[i] = copy.copy(t)
                if COLLECTED: COLLECTED['tested'][tokens[i].value] = 1
                if tokens[i].value in IGNORE:
                    tokens[i].type = 'IGNORE'
                else:
                    tokens[i].type = self.t_INTEGER
                    tokens[i].value = self.t_INTEGER_TYPE("0L")
            elif t.type == self.t_INTEGER:
                tokens[i] = copy.copy(t)
                # Strip off any trailing suffixes
                tokens[i].value = str(tokens[i].value)
                while tokens[i].value[-1] not in "0123456789abcdefABCDEF":
                    tokens[i].value = tokens[i].value[:-1]
        
            expr = "".join([('ignorer()' if x.type == 'IGNORE' else str(x.value)) for x in tokens])
            expr = expr.replace("&&"," and ")
            expr = expr.replace("||"," or ")
            expr = expr.replace("!"," not ")
            expr = re.sub('/\*[\s\S]*?\*/', '', expr)
            if expr == "0L  not = '#'": # handle special case
                expr = '1L'
        try:
            result = eval(expr)
        except IgnoreException:
            return 'ignore'
        except StandardError:
            if 'ignorer' in expr: return 'ignore'
            self.error(self.source,tokens[0].lineno,"Couldn't evaluate expression: %s" % expr)
            result = 0
        return result

    # ----------------------------------------------------------------------
    # parsegen()
    #
    # Parse an input string/
    # ----------------------------------------------------------------------
    def parsegen(self,input,source=None):

        # Replace trigraph sequences
        t = trigraph(input)
        lines = self.group_lines(t)

        if not source:
            source = ""
            
        self.source = source
        chunk = []
        enable = True
        iftrigger = False
        ifstack = []

        for x in lines:
            for i,tok in enumerate(x):
                if tok.type not in self.t_WS: break
            if tok.value == '#':
                # Preprocessor directive

                for tok in x:
                    if tok in self.t_WS and '\n' in tok.value:
                        chunk.append(tok)
                
                dirtokens = self.tokenstrip(x[i+1:])
                if dirtokens:
                    name = dirtokens[0].value
                    args = self.tokenstrip(dirtokens[1:])
                else:
                    name = ""
                    args = []

                if COLLECTED and name == 'define':
                    COLLECTED['defined'][args[0].value] = 1
                elif name == 'ifdef':
                    if COLLECTED: COLLECTED['tested'][args[0].value] = 1
                    ign = args[0].value in IGNORE
                    ifstack.append((enable,iftrigger,ign));
                    if enable:
                        if ign:
                            chunk.extend(x)
                            continue
                        if not args[0].value in self.macros:
                            enable = False
                            iftrigger = False
                        else:
                            iftrigger = True
                elif name == 'ifndef':
                    if COLLECTED: COLLECTED['tested'][args[0].value] = 1
                    ign = args[0].value in IGNORE
                    ifstack.append((enable,iftrigger,ign));
                    if enable:
                        if ign:
                            chunk.extend(x)
                            continue
                        if args[0].value in self.macros:
                            enable = False
                            iftrigger = False
                        else:
                            iftrigger = True
                elif name == 'if':
                    ifstack.append((enable,iftrigger,False))
                    if COLLECTED: result = self.evalexpr(args)
                    if enable:
                        result = self.evalexpr(args)
                        if result == 'ignore':
                            ifstack.pop()
                            ifstack.append((enable,iftrigger,True))
                            chunk.extend(x)
                            continue
                        if not result:
                            enable = False
                            iftrigger = False
                        else:
                            iftrigger = True
                elif name == 'elif':
                    if COLLECTED: result = self.evalexpr(args)
                    if ifstack:
                        if ifstack[-1][0]:     # We only pay attention if outer "if" allows this
                            if enable:         # If already true, we flip enable False
                                enable = False
                            elif not iftrigger:   # If False, but not triggered yet, we'll check expression
                                result = self.evalexpr(args)
                                if result == 'ignore':
                                    raise Exception('ERRRR!!! %s')
                                if result:
                                    enable  = True
                                    iftrigger = True
                    else:
                        self.error(self.source,dirtokens[0].lineno,"Misplaced #elif")
                        
                elif name == 'else':
                    if ifstack:
                        if ifstack[-1][0]:
                            if enable:
                                if ifstack[-1][2]: #ignoring
                                    chunk.extend(x)
                                    continue
                                enable = False
                            elif not iftrigger:
                                enable = True
                                iftrigger = True
                    else:
                        self.error(self.source,dirtokens[0].lineno,"Misplaced #else")

                elif name == 'endif':
                    if ifstack:
                        enable,iftrigger,ign = ifstack.pop()
                        if enable and ign:
                            chunk.extend(x)
                    else:
                        self.error(self.source,dirtokens[0].lineno,"Misplaced #endif")
                else:
                    if enable:
                        chunk.extend(x)
                    # # Unknown preprocessor directive
                    # pass

            else:
                # Normal text
                if enable:
                    chunk.extend(x)

        for tok in self.expand_macros(chunk):
            yield tok
        chunk = []

    # ----------------------------------------------------------------------
    # include()
    #
    # Implementation of file-inclusion
    # ----------------------------------------------------------------------

    def include(self,tokens):
        # Try to extract the filename and then process an include file
        if not tokens:
            return
        if tokens:
            if tokens[0].value != '<' and tokens[0].type != self.t_STRING:
                tokens = self.expand_macros(tokens)

            if tokens[0].value == '<':
                # Include <...>
                i = 1
                while i < len(tokens):
                    if tokens[i].value == '>':
                        break
                    i += 1
                else:
                    print "Malformed #include <...>"
                    return
                filename = "".join([x.value for x in tokens[1:i]])
                path = self.path + [""] + self.temp_path
            elif tokens[0].type == self.t_STRING:
                filename = tokens[0].value[1:-1]
                path = self.temp_path + [""] + self.path
            else:
                print "Malformed #include statement"
                return
        for p in path:
            iname = os.path.join(p,filename)
            try:
                data = open(iname,"r").read()
                dname = os.path.dirname(iname)
                if dname:
                    self.temp_path.insert(0,dname)
                for tok in self.parsegen(data,filename):
                    yield tok
                if dname:
                    del self.temp_path[0]
                break
            except IOError,e:
                pass
        else:
            print "Couldn't find '%s'" % filename

    # ----------------------------------------------------------------------
    # define()
    #
    # Define a new macro
    # ----------------------------------------------------------------------

    def define(self,tokens):
        if isinstance(tokens,(str,unicode)):
            tokens = self.tokenize(tokens)

        linetok = tokens
        try:
            name = linetok[0]
            if len(linetok) > 1:
                mtype = linetok[1]
            else:
                mtype = None
            if not mtype:
                m = Macro(name.value,[])
                self.macros[name.value] = m
            elif mtype.type in self.t_WS:
                # A normal macro
                m = Macro(name.value,self.tokenstrip(linetok[2:]))
                self.macros[name.value] = m
            elif mtype.value == '(':
                # A macro with arguments
                tokcount, args, positions = self.collect_args(linetok[1:])
                variadic = False
                for a in args:
                    if variadic:
                        print "No more arguments may follow a variadic argument"
                        break
                    astr = "".join([str(_i.value) for _i in a])
                    if astr == "...":
                        variadic = True
                        a[0].type = self.t_ID
                        a[0].value = '__VA_ARGS__'
                        variadic = True
                        del a[1:]
                        continue
                    elif astr[-3:] == "..." and a[0].type == self.t_ID:
                        variadic = True
                        del a[1:]
                        # If, for some reason, "." is part of the identifier, strip off the name for the purposes
                        # of macro expansion
                        if a[0].value[-3:] == '...':
                            a[0].value = a[0].value[:-3]
                        continue
                    if len(a) > 1 or a[0].type != self.t_ID:
                        print "Invalid macro argument"
                        break
                else:
                    mvalue = self.tokenstrip(linetok[1+tokcount:])
                    i = 0
                    while i < len(mvalue):
                        if i+1 < len(mvalue):
                            if mvalue[i].type in self.t_WS and mvalue[i+1].value == '##':
                                del mvalue[i]
                                continue
                            elif mvalue[i].value == '##' and mvalue[i+1].type in self.t_WS:
                                del mvalue[i+1]
                        i += 1
                    m = Macro(name.value,mvalue,[x[0].value for x in args],variadic)
                    self.macro_prescan(m)
                    self.macros[name.value] = m
            else:
                print "Bad macro definition"
        except LookupError:
            print "Bad macro definition"

    # ----------------------------------------------------------------------
    # parse()
    #
    # Parse input text.
    # ----------------------------------------------------------------------
    def parse(self,input,source=None,ignore={}):
        self.ignore = ignore
        self.parser = self.parsegen(input,source)
        
    # ----------------------------------------------------------------------
    # token()
    #
    # Method to return individual tokens
    # ----------------------------------------------------------------------
    def token(self):
        try:
            while True:
                tok = self.parser.next()
                if tok.type not in self.ignore: return tok
        except StopIteration:
            self.parser = None
            return None

lexer = lex.lex()

# Run a preprocessor
import sys
f = open(sys.argv[1])
input = f.read()
if len(sys.argv) > 2:
    collected = open('/tmp/collected.json')
    COLLECTED = json.load(collected)
    collected.close()


p = Preprocessor(lexer)
p.parse(input,sys.argv[1])
while True:
    tok = p.token()
    if not tok: break
    sys.stdout.write(tok.value)
if COLLECTED:
    collected = open('/tmp/collected.json', 'w')
    json.dump(COLLECTED, collected)
    collected.close()
EOF
chmod +x $cpp
# fi

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
# os_unix.c
# os_unix.h
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
# os_unix.pro
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

# echo '{"tested": {}, "defined": {}}' > /tmp/collected.json
cd src
for file in $src_remove; do
	rm -rf $file
done
# for file in *.(c|h); do
# 	echo collecting from $file
# 	$cpp $file true > /dev/null
# done

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
# for file in *.pro; do
# 	echo collecting from $file
# 	$cpp $file true > /dev/null
# done

# python << "EOF"
# import json
# collected = open('/tmp/collected.json')
# collected_data = json.load(collected)
# collected.close()
# ignored_data = []
# for k, v in collected_data['tested'].items():
#     if k in collected_data['defined']:
#         ignored_data.append(k)
# ignored_data.sort()
# ignored = open('/tmp/ignored.json', 'w')
# json.dump(ignored_data, ignored, indent=2)
# ignored.close()
# EOF
# exit

tmp=/tmp/processing-file
for file in *.pro; do
	print "processing $file"
	cp $file $tmp
	$cpp $tmp > $file
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
	$cpp $tmp > $file
	uncrustify -l c -c $uncrustify_cfg -f $file > $tmp
	cp $tmp $file
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
/# include "auto\/osdef\.h"/ d
/#include "feature\.h"/ d
EOF

sed -i '/#include "vim.h"/i#undef LC_MESSAGES' ex_cmds2.c

for file in $proto_remove; do
	sed -i "/$file/d" proto.h
done

sed -i '/EXTERN char_u\s*\*p_wig/iEXTERN char_u *p_wak;' option.h
sed -i '/gui_update_cursor/d' hangulin.c
vim -u NONE -E -s -c '%s/gui_redraw_block(\_.\{-});\n/\r/g' -c 'update' -c 'quit' hangulin.c || true

sed -i 's@^VIMPROG =.\+$@VIMPROG = ../../build/src/vim@' testdir/Makefile
sed -i 's@^VIM =.\+$@VIM = ../../build/src/vim@' po/Makefile
sed -i 's/\bDEBUG\b/REGEXP_DEBUG/g' regexp.c
sed -i 's/\bDEBUG\b/REGEXP_DEBUG/g' regexp_nfa.c

# fix some uncrustify errors
sed -i '2553s/> =/>=/' misc2.c
sed -i '4373s/> =/>=/' memline.c
sed -i '6867s/> =/>=/' spell.c
sed -i '4402s/> =/>=/' normal.c
sed -i -e '617s/> =/>=/' -e '752s/> =/>=/' ui.c


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
#define USE_XSMP_INTERACT 1

/* Temporary FEAT_* defines to make it compile */
#define FEAT_CMDWIN 1
#define FEAT_CON_DIALOG 1
#define FEAT_POSTSCRIPT 1
#define FEAT_CSCOPE 1
#define FEAT_EVAL 1
#define FEAT_FLOAT 1
#define FEAT_GETTEXT 1
#define FEAT_MBYTE 1
#define FEAT_MOUSE 1
#define FEAT_MOUSE_TTY 1
#define FEAT_MOUSE_XTERM 1
#define FEAT_MULTI_LANG 1
#define FEAT_SESSION 1
#define FEAT_TITLE 1
#define FEAT_SPELL 1
#define FEAT_STL_OPT 1
#define FEAT_SYN_HL 1
#define FEAT_TERMRESPONSE 1
#define FEAT_VERTSPLIT 1
#define FEAT_WINDOWS 1
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
