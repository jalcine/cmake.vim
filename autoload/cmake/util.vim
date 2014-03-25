" File:             autoload/cmake/util.vim
" Description:      Power methods for cmake.vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.1

func! cmake#util#binary_dir()
  if exists("b:cmake_binary_dir") && isdirectory(b:cmake_binary_dir)
    return b:cmake_binary_dir
  endif

  let l:proposed_dir = 0
  let l:directories = g:cmake_build_directories + [ getcwd() ]

  for l:directory in l:directories
    let l:directory = fnamemodify(l:directory, ':p:.')
    let l:file = findfile(directory . "/CMakeCache.txt", ".;")

    if filereadable(l:file)
      let l:proposed_dir = substitute(l:file, "/CMakeCache.txt", "", "")
      let b:cmake_binary_dir = l:proposed_dir
      break
    endif
  endfor

  return l:proposed_dir
endfunc

func! cmake#util#has_project()
  return cmake#util#binary_dir() == 0
endfunc

func! cmake#util#source_dir()
  if !cmake#util#has_project()
    return ""
  endif

  let dir = cmake#util#read_from_cache("Project_SOURCE_DIR")
  let dir = fnamemodify(dir, ':p:.')
  return l:dir
endfunc

func! cmake#util#cache_file_path()
  if cmake#util#has_project()
    return cmake#util#binary_dir() . "/CMakeCache.txt"
  endif

  return 0
endfunc

func! cmake#util#read_from_cache(property)
  let l:cmake_cache_file = cmake#util#cache_file_path()
  let l:property_width = strlen(a:property) + 2

  if !filereadable(cmake#util#cache_file_path())
    return ""
  endif

  " First, grep out this property.
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

" TODO Consider using 'sed'.
func! cmake#util#write_to_cache(property,value)
  call cmake#util#run_cmake('-D' . a:property . '=' . shellescape(a:value))
endfunc

func! cmake#util#run_make(command)
  let l:command = "make -C " . cmake#util#binary_dir() . " " . a:command
  call cmake#util#shell_exec(l:command)
endfunc

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

  let l:command = 'cd ' . l:binary_dir . '&& cmake ' . a:command . ' ' .
        \ l:binary_dir . ' ' . l:source_dir

  return cmake#util#shell_exec(l:command)
endfunc

" TODO Remove duplicates.
func! cmake#util#update_path()
  if cmake#util#has_project() == 1
    let l:paths = []
    let l:root_source_dir = cmake#util#source_dir()
    let l:root_binary_dir = cmake#util#binary_dir()

    if l:root_binary_dir != 0 && !empty(l:root_binary_dir)
      let l:paths += [ fnamemodify(l:root_binary_dir,':p:.') ]
    endif

    if l:root_source_dir != 0 && !empty(l:root_source_dir)
      let l:paths += [ fnamemodify(l:root_source_dir,':p:.') ]
    endif

    for target in cmake#targets#list()
      let l:target_source_dir = fnamemodify(cmake#targets#source_dir(l:target),':p:.')
      let l:target_binary_dir = fnamemodify(cmake#targets#binary_dir(l:target),':p:.')
      let l:target_include_dirs = cmake#targets#include_dirs(l:target)

      if count(l:paths, escape(l:target_source_dir, '\/'), 1) == 0
        let l:paths += [ l:target_source_dir ]
      endif

      if count(l:paths, escape(l:target_binary_dir, '\/'), 1) == 0
        let l:paths += [ l:target_binary_dir ]
      endif

      let l:paths += l:target_include_dirs
    endfor

    let l:all_paths = split(&path, ",", 0) + l:paths
    let l:paths_str = join(s:make_unique(l:all_paths), ",")
    let &path = l:paths_str
  endif
endfunc

function s:make_unique(list)
  let new_list = []
  for entry in a:list
    if count(new_list, entry, 1) == 1
      continue
    endif
    let l:new_list += [ entry ]
  endfor
  return l:new_list
endfunction

func! cmake#util#handle_injection()
  call cmake#commands#install_ex()
  call cmake#util#apply_makeprg()
  call cmake#util#update_path()
  call cmake#flags#inject()
endfunc

func! cmake#util#shell_exec(command)
  if g:cmake_use_dispatch == 1 && g:loaded_dispatch == 1
    return dispatch#compile_command("", a:command)
  elseif g:cmake_use_vimux == 1 && g:loaded_vimux == 1
    call VimuxRunCommand(a:command)
    return 0
  else
    return system(a:command)
  endif
endfunc

func! cmake#util#shell_bgexec(command)
  " Vimux isn't checked here because it focuses heavily on the use of
  " pane-based actions; whereas dispatch can use both the pane and window (if
  " necessary).
  if g:cmake_use_dispatch == 1 && g:loaded_dispatch == 1
    call dispatch#start(a:command, {'background': 1})
  else
    call cmake#util#shell_exec(a:command)
  endif
endfunc

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
  if g:cmake_set_makeprg == 1 && cmake#util#has_project() == 1
    let &makeprg="make -C " . cmake#util#binary_dir()
  endif
endfunc
