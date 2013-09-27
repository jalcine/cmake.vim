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

func! cmake#flags#inject_to_ycm(target)
  " The only way I've seen flags been 'injected' to YCM is via Python.
  " However, it only happened when YCM picked it up the Python source as
  " an external file to be used with the platform. This means that the
  " end user has to *want* to have us in that file. For now, we drop the
  " tags here, according to type and have the clever Python extension
  " we've added pick that up in the user's .ycm_extra_conf.py file a lá
  " `vim.cmake`.
  let l:flags = cmake#flags#target(a:target)
  exec("let b:cmake_flags=". string(l:flags))
endfunc!
