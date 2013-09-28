" File:             autoload/cmake/flags.vim
" Description:      Handles the act of injecting flags into Vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.2.11
" Last Modified:    2013-09-28 15:21:21 EDT

func! cmake#flags#parse(flagstr)
  let l:flags = split(a:flagstr)

  if g:cmake_flags.filter == 1
    for flag in flags
      let l:index = index(flags, flag)
      let l:isAInclude = stridx(flag, '-I')
      let l:isAIncludeFlagger = stridx(flag, '-i')
      let l:isAWarning = stridx(flag, '-W')
      let l:isValidFlag = !(isAInclude == -1 && 
      \ isAWarning == -1 &&
      \ isAIncludeFlagger == -1
      \ )

      if !isValidFlag
        echo flag . " " . index . " " . isAInclude . " " . isAIncludeFlagger . " " . isAWarning
        unlet flags[index]
        continue
      else
        if isdirectory(flag) && 
              \ (stridx(flags[index - 1], '-i') || stridx(flags[index - 1], '-I'))
          continue
        endif
      endif
    endfor
  endif

  return flags
endfunc!

func! cmake#flags#inject()
  if empty(g:cmake_inject_tags)
    return 0
  endif

  let target = cmake#targets#corresponding_file(fnamemodify(bufname('%'), ':p'))

  if !empty(target)
    call cmake#flags#inject_to_syntastic(target)
    call cmake#flags#inject_to_ycm(target)
  endif
endfunc

func! cmake#flags#inject_to_syntastic(target)
  if exists("g:loaded_syntastic_checker") && !empty(g:cmake_inject_flags.syntastic)
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
  if exists("g:ycm_check_if_ycm_core_present") && !empty(g:cmake_inject_flags.ycm)
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
