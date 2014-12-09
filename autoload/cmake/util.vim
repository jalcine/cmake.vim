" File:             autoload/cmake/util.vim
" Description:      Power methods for the CMake plugin.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

" Documentation: Local documentation.
" Documentation: In doc/cmake.txt

function s:get_sync_exec()
  return cmake#extension#default_func('exec','sync')
endfunction

function s:get_async_exec()
  return cmake#extension#default_func('exec','async')
endfunction

function! cmake#util#echo_msg(msg)
  if empty(a:msg)
    return
  endif

  redraw
  echomsg "[cmake] " . a:msg
  redraw
endfunction

function! cmake#util#echo_err(msg)
  if empty(a:msg)
    return
  endif

  redraw
  echoerr "[cmake] " . a:msg
  redraw
endfunction

" Function: cmake#util#binary_dir
" Returns: On success, A file path with a trailing slash that points to the
" CMake binary project. On failure, an empty string.
function! cmake#util#binary_dir()
  " If we defined the root binary directory, use it.
  if exists('g:cmake_root_binary_dir') && isdirectory(g:cmake_root_binary_dir)
    return g:cmake_root_binary_dir
  endif

  " Collect directories that we'd search for the existence of that magic
  " CMakeCache.txt file.
  let l:directories = g:cmake_build_directories + [ getcwd() ]

  " Walk over each directory upwards and check if the file exists in it.
  for l:directory in l:directories
    let l:directory = fnamemodify(l:directory, ':p')
    let l:file = findfile('CMakeCache.txt', l:directory . ';.')

    " Break out when we find something noteworthy.
    if filereadable(l:file)
      let g:cmake_root_binary_dir = fnamemodify(l:file, ':p:h')
      break
    endif
  endfor

  " Save our hard work so we can use it later.
  if exists('g:cmake_root_binary_dir')
    return g:cmake_root_binary_dir
  endif

  return 0
endfunc

" Function: cmake#util#source_dir
" Returns: On success, the path to the sources of the CMake project. On
" failure, an empty string.
function! cmake#util#source_dir()
  let l:root_cmakelists_file = findfile('CMakeLists.txt', getcwd() . ';' . cmake#util#binary_dir())
  let l:source_dir = substitute(l:root_cmakelists_file, 'CMakeLists.txt', '.', '')
  if l:source_dir == '.'
    let l:source_dir = getcwd()
  endif

  let l:source_dir = fnamemodify(l:source_dir, '%:p:h')
  return l:source_dir
endfunc

" Function: cmake#util#has_project
" Returns: On success, whether or not this project has been configured at least
" once.
function! cmake#util#has_project()
  let l:bindir = cmake#util#binary_dir()
  return filereadable(resolve(l:bindir . '/CMakeCache.txt'))
endfunc

" TODO: Allow a different 'make' executable to be used.
function! cmake#util#run_make(command)
  let l:command = 'make -C ' . cmake#util#binary_dir() . ' ' . a:command
  return cmake#util#shell_exec(l:command)
endfunc

" TODO: Allow a different 'cmake' executable to be used.
function! cmake#util#run_cmake(command)
  let l:command = 'cmake ' . a:command
  return cmake#util#shell_exec(l:command)
endfunc

function! cmake#util#shell_exec(command)
  let l:shell_sync_command=s:get_sync_exec()
  return {l:shell_sync_command}(a:command)
endfunc

function! cmake#util#shell_bgexec(command)
  let l:shell_async_command=s:get_async_exec()
  return {l:shell_async_command}(a:command)
endfunc
