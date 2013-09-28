" File:             autoload/cmake/targets.vim
" Description:      Handles the logic of interacting with targets.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.2.0
" Last Modified:    2013-09-28 15:21:40 EDT

func! cmake#targets#build(target)
  echomsg "[cmake] Building target '" . a:target . "'..."
  return cmake#util#run_cmake("--build " . cmake#util#binary_dir() . 
        \ " --target " . a:target . " -- ", "", "")
endfunc!

func! cmake#targets#clean()
  " TODO: This requires a bit of magic.
endfunc!

func! cmake#targets#binary_dir(target)
  let l:dir = glob(cmake#util#binary_dir() . '**/' . a:target . '.dir', 1)
  if isdirectory(l:dir)
    return l:dir
  endif

  return 0
endfunc!

func! cmake#targets#source_dir(target)
  let l:build_dir  = cmake#targets#binary_dir(a:target)
  let l:source_dir = substitute(l:build_dir,  
        \ cmake#util#binary_dir(), cmake#util#source_dir(), "g")
  let l:source_dir = substitute(l:source_dir,
        \ "/CMakeFiles/" . a:target . ".dir/", "", "g")
  let l:source_dir = fnamemodify(l:source_dir, ':p')
  return l:source_dir
endfunc!

func! cmake#targets#list()
  let dirs = glob(cmake#util#binary_dir() . '**/*.dir', 0, 1)
  for dir in dirs
    let oldir = dir
    let dir = substitute(dir, '^' . cmake#util#binary_dir(), '', 'g')
    let dir = substitute(dir, '.dir$', '', 'g')
    let dir = split(dir, '/')[-1]
    let dirs[index(dirs,oldir)] = dir
  endfor
  return dirs
endfunc!

func! cmake#targets#exists(target)
  return index(cmake#targets#list(), a:target) != -1
endfunc

func! cmake#targets#corresponding_file(filepath)
  " A bit intensive of a method, searches each target if the provided file is
  " within. This value is cached.
  if exists("b:cmake_corresponding_target")
    return b:cmake_corresponding_target
  endif

  for target in cmake#targets#list()
    if exists("l:files")
      unlet l:files
    endif
    let files = cmake#targets#files(target)

    if !empty(files) && index(files, fnamemodify(filepath, ':p')) != -1 
      let b:cmake_corresponding_target = l:target
      break
    else
      continue
    endif
  endfor

  if exists("b:cmake_corresponding_target")
    return b:cmake_corresponding_target
  endif

  return 0
endfunc!

func! cmake#targets#files(target)
  if !cmake#targets#exists(a:target)
    return 0
  endif

  let l:dependInternal = cmake#targets#binary_dir(a:target) . "/depend.internal"
  if !filereadable(l:dependInternal)
    return 0
  endif

  let l:objects = split(system('grep -E ".o$" ' . l:dependInternal), '\n')
  for object in objects
    let di = index(objects, object)
    let object = substitute(object,
     \ cmake#targets#binary_dir(a:target), cmake#targets#source_dir(a:target), 'g')
    let object = substitute(object, '.o$', '', 'g')
    let object = substitute(object, 'CMakeFiles/', '', 'g')
    let object = substitute(object, a:target . '.dir/', '', 'g')
    let object = fnamemodify(object, ':p')
    let objects[di] = object
  endfor

  return objects
endfunc!

func! cmake#targets#flags(target)
  if !cmake#targets#exists(a:target)
    return 0
  endif

  let l:flags_file = cmake#targets#binary_dir(a:target) . "/flags.make")

  if !filereadable(l:flags_file)
    return 0
  endif

  return { 
  \ "c"   : cmake#flags#parse(system("grep 'C_FLAGS = ' " . l:flags_file . " | cut -b 11-")),
  \ "cpp" : cmake#flags#parse(system("grep 'CXX_FLAGS = ' " . l:flags_file . " | cut -b 13-"))
  \  }
endfunc!
