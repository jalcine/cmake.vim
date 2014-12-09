" File:             autoload/ctags.vim
" Description:      Options to use ctags with CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

func s:get_tags()
  return &l:tags
endfunc

func s:set_tags(tags)
  let &l:tags = a:tags
endfunc

func! cmake#ctags#invoke(args)
  let command = g:cmake_ctags.executable . " " . a:args
  call cmake#util#shell_exec(l:command)
endfunc

func! cmake#ctags#cache_directory()
  let l:dir = fnamemodify(cmake#util#binary_dir() . '/tags', ':p')
  if !isdirectory(l:dir)
    call mkdir(l:dir)
  endif
  return l:dir
endfunc

func! cmake#ctags#filename(target)
  return simplify(cmake#ctags#cache_directory() . '/' .  a:target . '.tags')
endfunc

func! cmake#ctags#generate_for_target(target)
  let l:tag_file = cmake#ctags#filename(a:target)
  let l:files = cmake#targets#files(a:target)
  let l:args = '--append --excmd=mixed --extra=+fq --totals=no -f ' . l:tag_file

  if type(l:files) != type([])
    return
  endif

  for file in l:files
    let l:filepath = cmake#targets#source_dir(a:target) . '/' . l:file
    let l:command = l:args . ' ' . l:filepath
    call cmake#ctags#invoke(l:command)
  endfor

  if !empty(l:files)
    let g:cmake_cache.targets[a:target].tags_file = l:tag_file
  endif
endfunc

func! cmake#ctags#paths_for_target(target)
  let l:cache_dir = cmake#ctags#cache_directory()
  let l:tag_file = cmake#ctags#filename(a:target)
  let l:paths = split(&tags, ',')
  call filter(l:paths, 'filereadable(v:val)')

  if !filereadable(l:tag_file)
    call cmake#ctags#generate_for_target(a:target)
  endif

  call add(l:paths, l:tag_file)
  return l:paths
endfunc

func! cmake#ctags#refresh()
  call s:set_tags(join(cmake#ctags#paths_for_target(b:cmake_target), ','))
endfunc
