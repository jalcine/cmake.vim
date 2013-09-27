func! cmake#flags#target(target)
  let l:flags_file = glob(cmake#util#binary_dir() . '/**/' . a:target . '.dir/**/*flags.make')
  if len(l:flags_file) == 0
    return 0
  endif

  return { 
    \ "c"   : system("grep 'C_FLAGS = ' " . l:flags_file . " | cut -b 11-"),
    \ "cpp" : system("grep 'CXX_FLAGS = ' " . l:flags_file . " | cut -b 13-")
    \  }
endfunc!

func! cmake#flags#inject_to_syntastic(target)
  let l:flags = cmake#flags#target(a:target)

  for l:language in keys(l:flags)
    let l:checkers = eval("g:syntastic_" . l:language . "_checkers")
    for l:checker in l:checkers
      let l:args = l:flags[l:language]
      exec("let g:syntastic_" . l:language . "_" . l:checker . "_args = \"" . l:args . "\"")
    endfor
  endfor
endfunc!
