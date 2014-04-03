" File:             autoload/cmake/targets.vim
" Description:      Handles the logic of interacting with targets.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.1

func! cmake#targets#build(target)
  echomsg "[cmake] Building target '" . a:target . "'..."
  return cmake#util#run_cmake("--build . --target " . a:target . " -- ", "", "")
endfunc!

func! cmake#targets#exists(target)
  return index(cmake#targets#list(), a:target) != -1
endfunc

func! cmake#targets#binary_dir(target)
  let l:bindir = glob(cmake#util#binary_dir() . '/**/' . a:target . '.dir', 1)
  let l:bindir = expand(l:bindir, ':p:.')
  "echo 'Target binary dir: ' . l:bindir
  if isdirectory(l:bindir)
    return l:bindir
  endif

  return 0
endfunc!

func! cmake#targets#source_dir(target)
  let l:build_dir  = cmake#targets#binary_dir(a:target)
  let l:source_dir = substitute(l:build_dir,
        \ cmake#util#binary_dir(), cmake#util#source_dir(), "g")
  let l:source_dir = substitute(l:source_dir,
        \ "\/CMakeFiles\/" . a:target . ".dir/", "", "g")
  let l:source_dir = fnamemodify(l:source_dir, ':p:.')
  if !isdirectory(l:source_dir)
    let l:source_dir = 0
  endif
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

function! cmake#targets#include_dirs(target)
  let flags = cmake#targets#flags(a:target)
  let dirs = []
  if !empty(flags)
    for key in keys(flags)
      let includes = filter(flags[key], 'stridx(v:val, "-I") == 0')
      call map(includes, 'substitute(v:val, "-I", "", "")')
      let dirs += includes
    endfor
  endif

  return dirs
endfunction

func! cmake#targets#for_file(filepath)
  if exists("b:cmake_corresponding_target") &&
      \ cmake#targets#exists(b:cmake_corresponding_target)
    return b:cmake_corresponding_target
  endif

  let b:cmake_corresponding_target = 0

  for target in cmake#targets#list()
    if exists("l:files")
      unlet l:files
    endif
    let files = cmake#targets#files(target)

    if !empty(files) && index(files, fnamemodify(a:filepath, ':p')) != -1 
      let b:cmake_corresponding_target = l:target
      break
    else
      continue
    endif
  endfor

  return b:cmake_corresponding_target
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
    let object = substitute(object, '__', '', 'g')
    let object = substitute(object, '\/\/', '', 'g')
    let object = fnamemodify(object, ':p')
    let objects[di] = object
  endfor

  return objects
endfunc!

func! cmake#targets#flags(target)
  if !cmake#targets#exists(a:target)
    return 0
  endif

  let l:flags_file = cmake#targets#binary_dir(a:target) . '/flags.make'

  if !filereadable(l:flags_file)
    return 0
  endif

  " Scan flags.make for the flags and defines to be passed into the mix.
  return { 
    \ 'c'   : cmake#flags#collect(l:flags_file, 'C'),
    \ 'cpp' : cmake#flags#collect(l:flags_file, 'CXX')
    \ }
endfunc!
