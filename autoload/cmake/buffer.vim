" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.0

function! cmake#buffer#set_options()
  let l:current_file = expand('%')
  if !exists("b:cmake_target") || type(b:cmake_target) != type("")
    redraw | echo "[cmake.vim] Searching for target of '" . l:current_file . "'..."
    let b:cmake_target = cmake#targets#for_file(l:current_file)

    if empty(b:cmake_target) | return | endif

    if !exists('b:cmake_binary_dir')
      let b:cmake_binary_dir = cmake#targets#binary_dir(b:cmake_target)
    endif

    if !exists('b:cmake_source_dir')
      let b:cmake_source_dir = cmake#targets#source_dir(b:cmake_target)
    endif

    if !exists('b:cmake_include_dirs')
      let b:cmake_include_dirs = cmake#targets#include_dirs(b:cmake_target)
    endif

    if !exists('b:cmake_libraries')
      let b:cmake_libraries = cmake#targets#libraries(b:cmake_target)
    endif

    redraw | echo "[cmake.vim] Applied buffer options for '" . l:current_file . "'."
  endif
endfunction

function! cmake#buffer#set_makeprg()
  if g:cmake_set_makeprg == 1 && exists('b:cmake_target') && exists('b:cmake_root_binary_dir')
    let &makeprg="make -C " . b:cmake_root_binary_dir . " " . b:cmake_target
  endif
endfunc

function! cmake#buffer#has_project()
  let l:current_file = fnamemodify(expand('%'), ':p')

  if !filereadable(l:current_file)
    return 0
  endif

  if &ft != "cpp" && &ft != "c"
    return 0
  endif

  if !cmake#util#has_project()
    return 0
  endif

  return 1
endfunction
