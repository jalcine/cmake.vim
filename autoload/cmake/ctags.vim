" File:             autoload/ctags.vim
" Description:      Options to use ctags with CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.0

func! cmake#ctags#invoke(args)
  let command = g:cmake_ctags.executable . " " . a:args
  call cmake#util#shell_bgexec(l:command)
endfunc

func! cmake#ctags#cache_directory()
  let l:dir = fnamemodify(cmake#util#binary_dir() . "tags", "%:p")
  if !isdirectory(l:dir)
    call mkdir(l:dir)
  endif
  return l:dir
endfunc

func! cmake#ctags#generate_for_target(target)
  let l:tag_file = cmake#ctags#cache_directory() . "/" .  a:target . ".tags"
  let l:tag_file = fnamemodify(l:tag_file, ':p:.')
  let l:files    = cmake#targets#files(a:target)
  let l:args     = "--append --excmd=mixed --extra=+fq --totals=no --file " . l:tag_file

  if type(l:files) != type([])
    return
  endif

  for file in files
    let l:command = l:args . " " . l:file
    call cmake#ctags#invoke(l:command)
  endfor

  let &tags .= ',' . l:tag_file
endfunc
