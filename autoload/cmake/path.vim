" File:             autoload/cmake/path.vim
" Description:      Update le path in Vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

let s:failsafe_path="/usr/include,/usr/local/include,."

" Private Function: s:get_path
" Obtains the currently set path for the buffer.
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
  call map(new_list, 'expand(v:val, "%:p:h")')

  for entry in new_list
    let l:the_path = resolve(entry)
    if count(final_list, the_path, 1) == 1 || empty(the_path)
      continue
    endif

    let final_list += [ l:the_path ]
  endfor

  return final_list
endfunction

" Public Function: cmake#path#refresh
" Returns: Nothing
" Clears out '&l:path' and repopulates it with the new values fetched for this
" file's specific target and other values that were pre-exisiting before we
" fiddled with the global 'path'.
" TODO: Check if we ever need to fetch the global path settings; do Vim
" settings cascade?
func! cmake#path#refresh()
  call cmake#path#reset()
  call cmake#path#refresh_global_paths()
  call cmake#path#refresh_target_paths()
  return 1
endfunc

" Public Function: cmake#path#reset()
" Returns: Nothing.
" Resets the 'path' variable to be either the old 'path' value CMake had when
" it first loaded (the user provided one) or fall back to '/usr/include' and
" '/usr/local/include'.
func! cmake#path#reset()
  if exists('g:cmake_old_path') && !empty(g:cmake_old_path)
    call s:set_path(join(split(g:cmake_old_path, ',', 0), ','))
  else
    call s:set_path(s:failsafe_path)
  endif
endfunc

func! cmake#path#update(paths)
  let l:all_paths = split(g:cmake_old_path, ',', 1)
        \ + split(s:get_path(), ',', 1)
        \ + a:paths
  let l:paths_str = join(s:make_unique(l:all_paths), ',')
  call s:set_path(l:paths_str)
endfunc

func! cmake#path#refresh_global_paths()
  let l:paths = []
  let l:root_source_dir = cmake#util#source_dir()
  let l:root_binary_dir = cmake#util#binary_dir()

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
  let l:buffer_dir = expand('<afile>:p:h')
  let l:target = cmake#targets#for_file(expand('<afile>:p'))
  let l:target_source_dir = cmake#targets#source_dir(l:target)
  let l:target_binary_dir = cmake#targets#binary_dir(l:target)
  let l:target_include_dirs = cmake#targets#include_dirs(l:target)

  let l:paths += [
        \ l:buffer_dir,
        \ l:target_source_dir,
        \ l:target_binary_dir
        \ ]

  let l:paths += l:target_include_dirs
  call cmake#path#update(l:paths)
endfunc
