" File:             autoload/cmake/util.vim
" Description:      Power methods for cmake.vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.1

function! cmake#util#binary_dir()
  if exists("b:cmake_root_binary_dir") && isdirectory(b:cmake_root_binary_dir)
    return b:cmake_root_binary_dir
  endif

  let l:directories = g:cmake_build_directories + [ getcwd() ]

  for l:directory in l:directories
    let l:directory = fnamemodify(l:directory, ':p')
    let l:file = findfile(directory . "/CMakeCache.txt", ".;")

    if filereadable(l:file)
      let b:cmake_root_binary_dir = substitute(l:file, "/CMakeCache.txt", "", "")
      break
    endif
  endfor

  let b:cmake_root_binary_dir = fnamemodify(b:cmake_root_binary_dir,':p')
  return b:cmake_root_binary_dir
endfunc

function! cmake#util#source_dir()
  if !cmake#util#has_project()
    return ""
  endif

  let dir = fnamemodify(cmake#cache#read("Project_SOURCE_DIR"), ':p')
  return l:dir
endfunc

function! cmake#util#has_project()
  let l:bindir = cmake#util#binary_dir()
  if isdirectory(l:bindir)
    return filereadable(simplify(l:bindir . "/CMakeCache.txt"))
  else
    return ""
  endif
endfunc

function! cmake#util#run_make(command)
  let l:command = "make -C " . cmake#util#binary_dir() . " " . a:command
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
  if g:loaded_dispatch == 1
    return dispatch#compile_command(0, a:command)
  else
    return system(a:command)
  endif
endfunc

function! cmake#util#shell_bgexec(command)
  if g:cmake_use_dispatch == 1
    call dispatch#start(a:command, {'background': 1})
  else
    call cmake#util#shell_exec(a:command)
  endif
endfunc
