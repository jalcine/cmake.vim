" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

" Public Function: cmake#buffer#has_project
" Checks if the current buffer follows the following criteria:
"   - Has either the 'cpp' or 'c' formats applied.
"   - Does it exist in the file system.
"   - Check if this entire session has a CMake project associated with it.
" Returns: '1' if this current buffer relates to a CMake project. '0'
" otherwise.
func! cmake#buffer#has_project()
  let l:current_file = expand('%:p')

  " Ensure that this matches the filetypes we work with.
  if &l:ft != "cpp" && &l:ft != "c" && &l:ft != "cmake"
    return 0
  endif

  " If this file hasn't been saved yet, don't bother (it happens).
  if !filereadable(l:current_file)
    return 0
  endif

  " Pass it up the chain to the heavy-duty method.
  return cmake#util#has_project()
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
