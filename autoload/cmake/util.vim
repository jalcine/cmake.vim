" File:             autoload/cmake/util.vim
" Description:      Power methods for cmake.vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.2

function! cmake#util#binary_dir()
  if exists("b:cmake_root_binary_dir") && isdirectory(b:cmake_root_binary_dir)
    return b:cmake_root_binary_dir
  else
    let b:cmake_root_binary_dir = ""
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

  let dir = fnamemodify(cmake#util#read_from_cache("Project_SOURCE_DIR"), ':p')
  return l:dir
endfunc

function! cmake#util#cache_file_path()
  if cmake#util#has_project()
    return cmake#util#binary_dir() . "/CMakeCache.txt"
  endif

  return ""
endfunc

function! cmake#util#has_project()
  return empty(cmake#util#binary_dir())
endfunc

function! cmake#util#read_from_cache(property)
  if cmake#util#has_project() == 0
    return 0
  endif

  let l:cmake_cache_file = cmake#util#cache_file_path()
  let l:property_width = strlen(a:property) + 2

  " First, grep out this property.
  " TODO: Do this using Vim's string methods to make it more portable.
  let l:property_line = system("grep -E \"^" . a:property . ":\" " 
    \ . l:cmake_cache_file)
  if empty(l:property_line)
    return 0
  endif

  " Chop down the response to size.
  " TODO: Do this using Vim's string methods to make it more portable.
  let l:property_meta_value = system("echo '" . l:property_line . "' | cut -b "
    \ . l:property_width . "-")

  " Split it in half to get the resulting value and its type.
  let l:property_fields = split(l:property_meta_value, "=", 1)
  let l:property_fields[1] = substitute(l:property_fields[1], "\n", "", "g")
  return l:property_fields[1]
endfunc

function! cmake#util#write_to_cache(property,value)
  call cmake#util#run_cmake('-D' . a:property . ':STRING=' .
    \ shellescape(a:value))
endfunc

function! cmake#util#run_make(command)
  let l:command = "make -C " . cmake#util#binary_dir() . " " . a:command
  call cmake#util#shell_exec(l:command)
endfunc

function! cmake#util#run_cmake(command, binary_dir, source_dir)
  let l:binary_dir = a:binary_dir
  let l:source_dir = a:source_dir

  if empty(l:binary_dir) && empty(l:source_dir)
    let l:binary_dir = cmake#util#binary_dir()
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
    return dispatch#compile_command("", a:command)
  elseif g:cmake_use_vimux == 1 && g:loaded_vimux == 1
    call VimuxRunCommand(a:command)
    return 0
  else
    return system(a:command)
  endif
endfunc

function! cmake#util#shell_bgexec(command)
  " Vimux isn't checked here because it focuses heavily on the use of
  " pane-based actions; whereas dispatch can use both the pane and window (if
  " necessary).
  if g:cmake_use_dispatch == 1 && g:loaded_dispatch == 1
    call dispatch#start(a:command, {'background': 1})
  else
    call cmake#util#shell_exec(a:command)
  endif
endfunc

function! cmake#util#targets()
  let dirs = glob(cmake#util#binary_dir() ."**/*.dir", 0, 1)
  for dir in dirs
    let oldir = dir
    let dir = substitute(dir, cmake#util#binary_dir(), "", "g")
    let dir = substitute(dir, "**CMakeFiles/", "", "g")
    let dir = substitute(dir, ".dir", "", "g")
    let dirs[get(dirs, oldir)] = dir
  endfor
endfunc

function! cmake#util#set_buffer_options()
  let l:current_file       = fnamemodify(expand('%'), ':p')
  let b:cmake_target       = cmake#targets#for_file(l:current_file)
  let b:cmake_binary_dir   = cmake#targets#binary_dir(b:cmake_target)
  let b:cmake_source_dir   = cmake#targets#source_dir(b:cmake_target)
  let b:cmake_include_dirs = cmake#targets#include_dirs(b:cmake_target)
  let b:cmake_libraries    = cmake#targets#libraries(b:cmake_target)
endfunction

function! cmake#util#apply_makeprg()
  if g:cmake_set_makeprg == 1 && cmake#util#has_project() == 1
    let &makeprg="make -C " . b:cmake_root_binary_dir . " " . b:cmake_target
  endif
endfunc
