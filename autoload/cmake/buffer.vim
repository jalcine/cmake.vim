" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.5

" Public Function: cmake#buffer#has_project()
" Checks if the current buffer follows the following criteria:
"   - Checks if it currently exists in the file system.
"   - Checks if this entire session has a CMake project associated with it.
" Returns: '1' if this current buffer relates to a CMake project.
" Returns: '0' if any of the former conditions are unsatisfied.
func! cmake#buffer#has_project()
  " Make sure this is a normal buffer.
  if !empty(&buftype)
    return
  endif

  let l:current_file = expand('%:p')

  " Check if this file lives under the source or binary directory. This is a
  " sloppy way of doing it but it works.
  let l:in_srcdir = (stridx(l:current_file, cmake#util#source_dir()) == 0)
  let l:in_bindir = (stridx(l:current_file, cmake#util#binary_dir()) == 0)

  return cmake#util#has_project() && (l:in_bindir || l:in_srcdir)
endfunc

" Public Function: cmake#buffer_set_options()
" Returns: Nothing.
"
" Populates the buffer's local options with metadata that can be reused by other
" plugins and CMake itself.
func! cmake#buffer#set_options()
  if !cmake#buffer#has_project()
    call cmake#util#echo_msg("No project found.")
    return 0
  endif

  let l:current_file = expand('%:p:t')
  let b:cmake_target = cmake#targets#for_file(l:current_file)

  if !empty(b:cmake_target)
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
    return 1
  endif

  return 0
endfunc
