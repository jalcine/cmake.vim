func! cmake#flags#target(target)
  let l:flags_file = glob(cmake#util#binary_dir() . '**/' . a:target . '.dir/**/*flags.make', 1)
  if len(l:flags_file) == 0
    return 0
  endif

  return { 
        \ "c"   : split(system("grep 'C_FLAGS = ' " . l:flags_file . " | cut -b 11-")),
        \ "cpp" : split(system("grep 'CXX_FLAGS = ' " . l:flags_file . " | cut -b 13-"))
        \  }
endfunc!

func! cmake#flags#inject(target)
  call cmake#flags#inject_to_syntastic(a:target)
  call cmake#flags#inject_to_ycm(a:target)
endfunc

func! cmake#flags#inject_to_syntastic(target)
  if exists("g:loaded_syntastic_checker")
    let l:flags = cmake#flags#target(a:target)
    for l:language in keys(l:flags)
      let l:checkers = eval("g:syntastic_" . l:language . "_checkers")
      for l:checker in l:checkers
        let l:args = l:flags[l:language]
        exec("let g:syntastic_" . l:language . "_" . l:checker . "_args ='" . join(l:args, " ") . "'")
      endfor
    endfor
  endif
endfunc!

func! cmake#flags#inject_to_ycm(target)
  if exists("g:ycm_check_if_ycm_core_present")
    " The only way I've seen flags been 'injected' to YCM is via Python.
    " However, it only happened when YCM picked it up the Python source as
    " an external file to be used with the platform. This means that the
    " end user has to *want* to have us in that file. For now, we drop the
    " tags here, according to type and have the clever Python extension
    " we've added pick that up in the user's .ycm_extra_conf.py file a lá
    " `vim.cmake`.
    if exists("b:cmake_flags")
      unlet b:cmake_flags
    endif

    exec("let b:cmake_flags=". string(cmake#flags#target(a:target)))
  endif
endfunc!

func! s:check_to_inject()
  " TODO: When we can do file-based target detection, we use that file to
  " determine the target. If &ft is in the keys for b:cmake_flags then we use
  " only those flags in cmake#flags#inject_to_*.

  " Better yet, just use ftdetect/{cpp,c}/cmake.vim to do the magic.
endfunc!

augroup cmake_inject
  au!
  au BufReadPost * :call s:check_to_inject()
augroup END
