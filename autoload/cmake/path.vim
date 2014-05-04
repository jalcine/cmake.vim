" File:             autoload/cmake/path.vim
" Description:      Update le path in Vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.2-1

func! cmake#path#refresh()
  call cmake#path#reset_path()
  if cmake#buffer#has_project() == 1
    call cmake#path#refresh_global_paths()
    call cmake#path#refresh_target_paths()
  endif
endfunc


func! cmake#path#reset_path()
  if !exists('g:cmake_old_path')
    let &path = split(g:cmake_old_path, ",", 0)
  else
    let &path = '.:/usr/include'
  endif
endfunc

func! cmake#path#update(paths)
  let l:all_paths = s:make_unique(a:paths) + split(g:cmake_old_path, ",", 0)
  let l:paths_str = join(s:make_unique(l:all_paths), ",")
  let &path = l:paths_str
endfunc

func! cmake#path#refresh_global_paths()
  let l:paths = []
  let l:root_source_dir = fnamemodify(cmake#util#source_dir(), ':p:.')
  let l:root_binary_dir = fnamemodify(cmake#util#binary_dir(), ':p:.')

  if isdirectory(l:root_binary_dir)
    let l:paths += [ l:root_binary_dir ]
  endif

  if isdirectory(l:root_source_dir)
    let l:paths += [ l:root_source_dir ]
  endif

  call cmake#path#update(l:paths)
endfunc

func! cmake#path#refresh_target_paths()
  let l:paths = []
  let l:target = cmake#targets#for_file(expand('%:p'))
  let l:buffer_dir = expand('%:h:.') . '/'
  let l:target_source_dir = fnamemodify(cmake#targets#source_dir(l:target),':p:.')
  let l:target_binary_dir = fnamemodify(cmake#targets#binary_dir(l:target),':p:.')
  let l:target_include_dirs = cmake#targets#include_dirs(l:target)

  let l:paths += [ l:buffer_dir, './' ]

  if count(l:paths, escape(l:target_source_dir, '\/'), 1) == 0
    let l:paths += [ l:target_source_dir ]
  endif

  if count(l:paths, escape(l:target_binary_dir, '\/'), 1) == 0
    let l:paths += [ l:target_binary_dir ]
  endif

  let l:paths += l:target_include_dirs
  call cmake#path#update(l:paths)
endfunc

function! s:make_unique(list)
  let new_list = []
  for entry in a:list
    if count(new_list, entry, 1) == 1
      continue
    endif
    if type(entry) != type("") || entry == "0"
      let l:new_list += [ fnamemodify('.',':p:~') ]
    else
      let l:new_list += [ fnamemodify(entry,':p:.') ]
    endif
  endfor
  call filter(l:new_list, 'empty(v:val) == 0')
  return l:new_list
endfunction
