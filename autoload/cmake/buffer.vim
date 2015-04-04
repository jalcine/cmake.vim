" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.5

" Public Function: cmake#buffer#has_project()
" Checks if the current buffer lives under either the source or binary dir.
" Returns: '1' if the current buffer exists under the CMake sources.
" Returns: '0' if the current buffer does not exist under the CMake sources.
func! cmake#buffer#has_project()
  if !empty(&buftype)
    return
    " Make sure this is a normal buffer.
  endif

  let l:current_file = expand('%:p')

  " Check if this file lives under the source or binary directory.
  let l:in_srcdir = (stridx(l:current_file, cmake#util#source_dir(), 0) == 0)
  let l:in_bindir = (stridx(l:current_file, cmake#util#binary_dir(), 0) == 0)

  return cmake#util#has_project() && (l:in_bindir || l:in_srcdir)
endfunc

" Public Function:
" Returns:
func! cmake#buffer#set_options()
  let l:current_file = expand('%:p:t')

  if !cmake#buffer#has_project()
    return 0
  endif

  let b:cmake_target = cmake#targets#for_file(l:current_file)

  if empty(b:cmake_target)
    unlet b:cmake_target
  else
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

    call cmake#extension#flex({ 'target' : b:cmake_target })
  endif
  return 1
endfunc
