" File:             autoload/cmake/util.vim
" Description:      Power methods for the CMake plugin.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.3

function! cmake#util#echo_msg(msg)
  if empty(a:msg) | return | endif
  redraw | echomsg "[cmake] " . a:msg | redraw
endfunction

" Function: cmake#util#binary_dir
" Returns: On success, A file path with a trailing slash that points to the 
" CMake binary project. On failure, an empty string.
function! cmake#util#binary_dir()
  if exists('g:cmake_root_binary_dir') && isdirectory(g:cmake_root_binary_dir)
    return g:cmake_root_binary_dir
  endif

  " Collect directories that we'd search for the existance of that magic
  " CMakeCache.txt file.
  let l:directories = g:cmake_build_directories + [ getcwd() ]

  " Walk over each directory upwards and check if the file exists in it.
  for l:directory in l:directories
    let l:directory = fnamemodify(l:directory, ':p')
    let l:file = findfile(directory . '/CMakeCache.txt', '.;')

    " Break out when we find something noteworthy.
    if filereadable(l:file)
      let g:cmake_root_binary_dir = simplify(fnamemodify(substitute(l:file, 
            \ '/CMakeCache.txt', '', ''), ':p'))
      break
    endif
  endfor

  " Save our hard work so we can use it later.
  if exists('g:cmake_root_binary_dir')
    return g:cmake_root_binary_dir
  endif

  return ""
endfunc

" Function: cmake#util#source_dir
" Returns: On success, the path to the sources of the CMake project. On
" failure, zero.
function! cmake#util#source_dir()
  if !cmake#util#has_project()
    return ""
  endif

  let dir = fnamemodify(cmake#cache#read('Project_SOURCE_DIR'), ':p')
  return l:dir
endfunc

" Function: cmake#util#has_project
" Returns: On success, whether or not this project has been configured at least
" once.
function! cmake#util#has_project()
  let l:bindir = cmake#util#binary_dir()
  if isdirectory(l:bindir)
    return filereadable(simplify(l:bindir . '/CMakeCache.txt'))
  else
    return 0
  endif
endfunc

function! cmake#util#run_make(command)
  let l:command = 'make -C ' . cmake#util#binary_dir() . ' ' . a:command
  call cmake#util#shell_exec(l:command)
endfunc

function! cmake#util#run_cmake(command, binary_dir, source_dir)
  let l:binary_dir = a:binary_dir
  let l:source_dir = a:source_dir

  " Auto-default to the root binary directory.
  if empty(l:binary_dir) && empty(l:source_dir)
    let l:binary_dir = cmake#util#binary_dir()
    let l:source_dir = cmake#util#source_dir()
  endif

  if empty(l:source_dir) && !empty(l:binary_dir)
    let l:source_dir = cmake#util#source_dir()
  endif

  if !empty(l:source_dir) && empty(l:binary_dir)
    let l:binary_dir = "/tmp/vim-cmake-" . tempname()
    call mkdir(l:binary_dir)
  endif

  let l:command = 'cd ' . l:binary_dir . ' && cmake ' . a:command . ' ' .
    \ l:binary_dir . ' ' . l:source_dir

  return cmake#util#shell_exec(l:command)
endfunc

function! cmake#util#shell_exec(command)
  if g:cmake_use_dispatch == 1 && g:loaded_dispatch == 1
    execute 'Dispatch ' . a:command . '<CR>'
  else
    return system(a:command)
  endif
endfunc

function! cmake#util#shell_bgexec(command)
  if g:cmake_use_dispatch == 1
    execute 'Start! ' . a:command . '<CR>'
  else
    call cmake#util#shell_exec(a:command)
  endif
endfunc
