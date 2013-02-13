" runtime! syntax/mustache.vim
" runtime! syntax/html.vim
unlet b:current_syntax

if exists("b:current_syntax")
  finish
endif


syntax match mustacheErrorL '\]\]\]\?'
syntax match mustacheInsideErrorL '\[\[[{#<>=!\/]\?' containedin=@mustacheInsideL
syntax region mustacheVariableL matchgroup=mustacheMarkerL start=/\[\[/ end=/\]\]/ containedin=@htmlMustacheContainerL
syntax region mustacheVariableUnescapeL matchgroup=mustacheMarkerL start=/\[\[\[/ end=/\]\]\]/ containedin=@htmlMustacheContainerL
syntax region mustacheSectionL matchgroup=mustacheMarkerL start='\[\[[\^#/]' end=/\]\]/ containedin=@htmlMustacheContainerL
syntax region mustachePartialL matchgroup=mustacheMarkerL start=/\[\[[<>]/ end=/\]\]/
syntax region mustacheMarkerSetL matchgroup=mustacheMarkerL start=/\[\[=/ end=/=\]\]/
syntax region mustacheCommentL start=/\[\[!/ end=/\]\]/ contains=Todo containedin=htmlHead


" Clustering
syntax cluster mustacheInsideL add=mustacheVariableL,mustacheVariableUnescapeL,mustacheSectionL,mustachePartialL,mustacheMarkerSetL
syntax cluster htmlMustacheContainerL add=htmlHead,htmlTitle,htmlString,htmlH1,htmlH2,htmlH3,htmlH4,htmlH5,htmlH6


" Hilighting
" mustacheInside hilighted as Number, which is rarely used in html
" you might like change it to Function or Identifier
hi def link mustacheVariableL Identitifer
hi def link mustacheVariableUnescapeL Identifier
hi def link mustachePartialL Identifier
hi def link mustacheSectionL Identifier
hi def link mustacheMarkerSetL Identifier

hi def link mustacheCommentL Comment
hi def link mustacheMarkerL Function
hi def link mustacheErrorL Error
hi def link mustacheInsideErrorL Error

let b:current_syntax = "html-mustache"
