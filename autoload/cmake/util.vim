" File:             autoload/cmake/util.vim
" Description:      Power methods for cmake.vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.2.2
" Last Modified:    2013-09-28 15:21:31 EDT

func! cmake#util#binary_dir()
  " If we found it already, don't waste effort.
  if exists("b:cmake_binary_dir")
    return b:cmake_binary_dir
  endif

  let l:proposed_dir = 0

  " Check in the currenty directory as well.
  let l:directories = g:cmake_build_directories + [ getcwd() ]

  for l:directory in l:directories
    let l:directory = fnamemodify(l:directory, ':p')
    " TODO: Make paths absolute.
    let l:proposed_cmake_file = findfile(directory . "/CMakeCache.txt", ".;")

    if filereadable(l:proposed_cmake_file)
      " If we found it, drop off that CMakeCache.txt reference and cache the
      " value to this buffer.
      let l:proposed_dir = substitute(l:proposed_cmake_file, "/CMakeCache.txt", "", "")
      let b:cmake_binary_dir = l:proposed_dir
    endif
  endfor

  return l:proposed_dir
endfunc!

" TODO; Resolve path to absolute-ness.
func! cmake#util#source_dir()
  if cmake#util#binary_dir() == 0
    return ""
  endif

  return cmake#util#read_from_cache("Project_SOURCE_DIR")
endfunc!

func! cmake#util#cache_file_path()
  let l:bindir = cmake#util#binary_dir()
  if isdirectory(l:dir) && filereadable(l:bindir . "/CMakeCache.txt")
    return l:bindir . "/CMakeCache.txt"
  endif

  return 0
endfunc!

func! cmake#util#read_from_cache(property)
  let l:cmake_cache_file = cmake#util#cache_file_path()
  let l:property_width = strlen(a:property) + 2

  " If we can't find the cache file, then there's no point in trying to read
  " it.
  if !filereadable(cmake#util#cache_file_path())
    return ""
  endif

  " First, grep out this property.
  let l:property_line = system("grep -E \"^" . a:property . ":\" " . l:cmake_cache_file)
  if empty(l:property_line)
    return 0
  endif

  " Chop down the response to size.
  let l:property_meta_value = system("echo '" . l:property_line . "' | cut -b " . l:property_width . "-")

  " Split it in half to get the resulting value and its type.
  let l:property_fields = split(l:property_meta_value, "=", 1)
  let l:property_fields[1] = substitute(l:property_fields[1], "\n", "", "g")

  return l:property_fields
endfunc!

func! cmake#util#write_to_cache(property,value)
  call cmake#util#run_cmake('-D' . a:property . '=' . shellescape(a:value))
endfunc!

func! cmake#util#run_make(command)
  let l:command = "make -C " . cmake#util#binary_dir() . " " . a:command
  if g:cmake_use_vimux == 1 && g:loaded_vimux == 1
    call VimuxRunCommand(l:command)
  else if g:cmake_set_makeprg == 1
    call make(a:command) 
  endif
endfunc!

func! cmake#util#run_cmake(command, binary_dir, source_dir)
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

  let l:command = 'PWD=' . l:binary_dir . ' cmake ' . a:command . ' ' .
        \ l:binary_dir . ' ' . l:source_dir

  return cmake#util#shell_exec(l:command)
endfunc!

func! cmake#util#handle_injection()
  call cmake#util#apply_makeprg()
  call cmake#commands#install_ex()
  call cmake#flags#inject()
endfunc!

func! cmake#util#shell_exec(command)
  if g:cmake_use_vimux == 1 && g:loaded_vimux == 1
    call VimuxRunCommand(a:command)
    return 0
  else
    return system(a:command)
  endif
endfunc!

func! cmake#util#targets()
  let dirs = glob(cmake#util#binary_dir() ."**/*.dir", 0, 1)
  for dir in dirs
    let oldir = dir
    let dir = substitute(dir, cmake#util#binary_dir(), "", "g")
    let dir = substitute(dir, "**CMakeFiles/", "", "g")
    let dir = substitute(dir, ".dir", "", "g")
    let dirs[get(dirs, oldir)] = dir
  endfor
endfunc

func! cmake#util#apply_makeprg()
  let build_dir = cmake#util#binary_dir()
  if exists('g:cmake_set_makeprg') && g:cmake_set_makeprg == 1
    let &makeprg="make -C " . l:build_dir
  endif
endfunc!
