" Vim color file
" Maintainer:	Eskild Hustvedt <eskild at zerodogg dot org>
" Last Change:	$Date: 2008-06-17 13:22:08 +0200 (ty., 17 juni 2008) $
" Version:	$Id: gui_default_tango.vim 2732 2008-06-17 11:22:08Z zerodogg $
" License: GNU General Public License version 3 or (at your option) any later
" 			version as published by the Free Software Foundation.
"
" This file attempts to emulate the look of running vim with the default
" colourscheme running in a GNOME Terminal with the tango terminal colour
" scheme.
" It does not change any of the default console settings.

" This is a list of Console_color_number = GUI color.
" The colour name is the colours that was used for the most (not always
" accurate).
"
" 0/Black/LightGrey = #2E3436
" 1/Red = #CC0000
" 2/SeaGreen = #4E9A06
" 3/Yellow/Brown = #C4A000
" 4/Blue = #3465A4
" 5/Magneta/LightMagneta = #75507B
" 6/DarkBlue = #06989A
" 7/Grey = #D3D7CF
" 8 = #555753
" 9 = #EF2929
" 10 = #8AE234
" 11 = #FCE94F
" 12 = #729FCF
" 13 = #AD7FA8
" 14 = #34E2E2
" 15/White = #EEEEEC

set background=dark
if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
	syntax reset
    endif
endif
let g:colors_name="darktango"

hi SpecialKey guifg=#3465A4
hi NonText guifg=#3465A4
hi Directory guifg=#3465A4
hi ErrorMsg guifg=#EEEEEC guibg=#CC0000
hi Search guibg=#C4A000
hi MoreMsg guifg=#4E9A06
hi LineNr guifg=#C4A000
hi Question guifg=#4E9A06
hi Title guifg=#75507B
hi Visual guifg=NONE
hi WarningMsg guifg=#CC0000
hi WildMenu guifg=#2E3436 guibg=#C4A000
hi Folded guifg=#06989A guibg=#2E3436
hi FoldedColumn guifg=#3465A4 guibg=#D3D7CF
hi DiffAdd guibg=#3465A4
hi DiffChange guibg=#75507B
hi DiffDelete guifg=#3465A4 guifg=#06989A
hi DiffText guibg=#CC0000
hi SignColumn guifg=#3465A4 guibg=#CC0000
hi SpellBad guisp=#CC0000
hi SpellCap guisp=#3465A4
hi Spellrare guisp=#75507B
hi SpellLocal guisp=#06989A
hi Pmenu guibg=#75507B
hi PmenuSel guibg=#D3D7CF
hi PmenuSbar guibg=#D3D7CF
hi TabLine guibg=#D3D7CF guifg=#2E3436
hi CursorColumn guibg=#D3D7CF
hi CursorLine gui=underline guibg=NONE
hi MatchParen guibg=#06989A
hi Comment guifg=#305d97
hi Constant guifg=#CC0000
hi Special guifg=#75507B
hi Identifier guifg=#06989A
hi Statement guifg=#C4A000 gui=NONE
hi PreProc guifg=#75507B
hi Type guifg=#4b9506 gui=None
hi Underlined guifg=#75507B
hi Ignore guifg=#D3D7CF
hi Error guifg=#D3D7CF guibg=#CC0000
hi Todo guifg=#2E3436 guibg=#C4A000
hi Normal guifg=White guibg=Black

