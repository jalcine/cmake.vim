" File:             autoload/cmake/flags.vim
" Description:      Handles the act of injecting flags into Vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.2.2
" Last Modified:    2013-09-28 15:21:21 EDT

func! cmake#flags#parse(flagstr)
  let l:flags = split(a:flagstr)

  if g:cmake_filter_flags == 1
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
  if empty(g:cmake_inject_flags)
    return 0
  endif

  let target = cmake#targets#corresponding_file(fnamemodify(bufname('%'), ':p'))

  if !empty(target)
    call cmake#flags#inject_to_ycm(target)
    call cmake#flags#inject_to_syntastic(target)
  endif
endfunc

func! cmake#flags#inject_to_syntastic(target)
  if g:cmake_inject_flags.syntastic != 1
    return
  endif

  let l:flags = cmake#targets#flags(a:target)
  if empty(l:flags)
    return
  endif

  for l:language in keys(l:flags)
    let l:checker_val = "g:syntastic_" . l:language . "_checkers"
    if !exists(l:checker_val)
      continue
    endif

    let l:checkers = eval(l:checker_val)
    for l:checker in l:checkers
      let l:args = l:flags[l:language]
      let l:sy_flag = "g:syntastic_" . l:language . "_" . l:checker . "_args"
      exec("let " . l:sy_flag . "='" . join(l:args, " ") . "'")
    endfor
  endfor
endfunc!

func! cmake#flags#inject_to_ycm(target)
  if g:cmake_inject_flags.ycm != 1
    return
  endif

  " First, let's pass in the flags that one could add in directly for
  " individual targets for the .ycm_extra_conf.py.
  let b:cmake_flags = string(cmake#targets#flags(a:target)[&filetype])
  if empty(g:ycm_extra_conf_vim_data)
    let g:ycm_extra_conf_vim_data = ['b:cmake_flags']
  elseif get(g:ycm_extra_conf_vim_data,'b:cmake_flags','NONE') == 'NONE'
    add(ycm_extra_conf_vim_data,'b:cmake_flags')
  endif

  " Secondly, provide the full path where the JSON compilation file could be
  " found. This will eventually be the final solution moving forward for
  " building individual files.
  let b:cmake_json_compilation_database_file = b:cmake_binary_dir 
    \ . "/compile_commands.json"
endfunc!
