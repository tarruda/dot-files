fun! GetFoldLevel(lnum)
  if getline(a:lnum) =~? '\v^\s*$'
    return '-1'
  endif
  let this_indent = s:IndentLevel(a:lnum)
  let next_indent = s:IndentLevel(s:NextNonBlankLine(a:lnum))
  if next_indent == this_indent
    return this_indent
  elseif next_indent < this_indent
    return this_indent
  elseif next_indent > this_indent
    return '>' . next_indent
  endif
endfun

fun! s:NextNonBlankLine(lnum)
  let numlines = line('$')
  let current = a:lnum + 1
  while current <= numlines
    if getline(current) =~? '\v\S'
      return current
    endif
    let current += 1
  endwhile
  return -2
endfun

fun! s:IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth
endfun
