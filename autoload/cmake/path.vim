" File:             autoload/cmake/path.vim
" Description:      Update le path in Vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.5

func s:get_path()
  return &l:path
endfunc

func s:set_path(path)
  let &l:path = a:path
endfunc

function! s:make_unique(list)
  let new_list = a:list
  let final_list = []
  let l:the_path = ""
  call map(new_list, 'fnamemodify(expand(v:val), ":p")')

  for entry in new_list
    let l:the_path = simplify(fnamemodify(entry,':p'))
    if count(final_list, the_path, 1) == 1 || !isdirectory(the_path)
      continue
    endif

    let final_list += [ l:the_path ]
  endfor

  return final_list
endfunction

func! cmake#path#refresh()
  call cmake#path#reset_path()
  call cmake#path#refresh_global_paths()
  call cmake#path#refresh_target_paths()
endfunc

func! cmake#path#reset_path()
  if !exists('g:cmake_old_path')
    call s:set_path(split(g:cmake_old_path, ',', 0))
  else
    call s:set_path('.,/usr/include')
  endif
endfunc

func! cmake#path#update(paths)
  let l:all_paths = split(g:cmake_old_path, ',', 0) + split(s:get_path(), ',', 0) + a:paths
  let l:paths_str = join(s:make_unique(l:all_paths), ',')
  call s:set_path(l:paths_str)
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
  let l:buffer_dir = expand('%:h:.') . '/'
  let l:target = cmake#targets#for_file(expand('%:p'))
  let l:target_source_dir = cmake#targets#source_dir(l:target)
  let l:target_binary_dir = cmake#targets#binary_dir(l:target)
  let l:target_include_dirs = cmake#targets#include_dirs(l:target)

  let l:paths += [ l:buffer_dir, '.',
        \ l:target_source_dir, l:target_binary_dir ]
  let l:paths += l:target_include_dirs

  call cmake#path#update(l:paths)
endfunc
