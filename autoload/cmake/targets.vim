" File:             autoload/cmake/targets.vim
" Description:      Handles the logic of interacting with targets.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.2-1

function! cmake#targets#build(target)
  echomsg "[cmake] Building target '" . a:target . "'..."
  return cmake#util#run_cmake("--build . --target " . a:target . " -- ", "", "")
endfunction!

function! cmake#targets#exists(target)
  return index(cmake#targets#list(), a:target) != -1
endfunc

function! cmake#targets#binary_dir(target)
  let l:bindir = glob(cmake#util#binary_dir() . '/**/' . a:target . '.dir', 1)
  let l:bindir = fnamemodify(l:bindir, ':p')
  let l:bindir = resolve(l:bindir)
  return l:bindir
endfunction!

function! cmake#targets#source_dir(target)
  let l:build_dir  = fnamemodify(cmake#targets#binary_dir(a:target), ':p')
  let l:source_dir = ""
  if !isdirectory(l:build_dir)
    return l:source_dir
  endif
  let l:root_binary_dir = fnamemodify(cmake#util#binary_dir(), ':p')
  let l:root_source_dir = fnamemodify(cmake#util#source_dir(), ':p')

  let l:source_dir = fnamemodify(substitute(l:build_dir, l:root_binary_dir, 
        \ l:root_source_dir, ""), ':p')
  let l:source_dir = fnamemodify(substitute(l:source_dir, "\/CMakeFiles\/" . 
        \ a:target . ".dir\/", "", ""), ':p')
  let l:source_dir = resolve(l:source_dir)
  return l:source_dir
endfunction!

function! cmake#targets#list()
  let l:bin_dir = cmake#util#binary_dir()
  if !isdirectory(l:bin_dir)
    return []
  endif

  let dirs = glob(l:bin_dir . '**/*.dir', 0, 1)
  for dir in dirs
    let oldir = dir
    let dir = substitute(dir, '^' . l:bin_dir, '', 'g')
    let dir = substitute(dir, '.dir$', '', 'g')
    let dir = split(dir, '/')[-1]
    let dirs[index(dirs,oldir)] = dir
  endfor
  return dirs
endfunction!

function! cmake#targets#include_dirs(target)
  let flags = cmake#targets#flags(a:target)
  let dirs = []
  if !empty(flags)
    for key in keys(flags)
      let includes = filter(copy(flags[key]), 'stridx(v:val, "-I") == 0')
      call map(includes, 'substitute(v:val, "-I", "", "")')
      let dirs += includes
    endfor
  endif

  return dirs
endfunction

function! cmake#targets#libraries(target)
  " TODO: Get the libraries from link.txt
  return []
endfunction

function! cmake#targets#for_file(filepath)
  for target in cmake#targets#list()
    let files = cmake#targets#files(target)
    if !empty(files) && index(files, fnamemodify(a:filepath, ':p:.')) != -1 
      return l:target
    endif
  endfor

  return ""
endfunction!

function! cmake#targets#files(target)
  if !cmake#targets#exists(a:target)
    echomsg "[cmake.vim] No target named '" . a:target . "'."
    return []
  endif

  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:srcdir = cmake#targets#source_dir(a:target)

  let l:dependInternal = fnamemodify(l:bindir . "/depend.internal", ':p')
  if !filereadable(l:dependInternal)
    return []
  endif

  let l:objects = readfile(l:dependInternal)
  let l:objects = filter(l:objects, 'v:val =~ "\.o$" ')
  for object in objects
    let di = index(objects, object)
    let object = fnamemodify(object, ':p')
    let object = substitute(object, fnamemodify(l:bindir, ':p:.'), '', 'g')
    let object = substitute(object, fnamemodify(l:srcdir, ':p:.'), '', 'g')
    let object = substitute(object, '.o$', '', 'g')
    let object = substitute(object, 'CMakeFiles/', '', 'g')
    let object = substitute(object, a:target . '.dir/', '', 'g')
    let object = substitute(object, '__', '', 'g')
    let object = substitute(object, '\/\/', '', 'g')
    let object = fnamemodify(l:srcdir . '/' . object, ':p')
    let objects[di] = object
  endfor

  call filter(objects, 'filereadable(v:val) == 1')
  call map(objects, 'fnamemodify(v:val, ":p:.")')
  return objects
endfunction!

function! cmake#targets#flags(target)
  let flags = { 'c' : [], 'cpp' : [] }

  if cmake#targets#exists(a:target)
    let l:flags_file = cmake#targets#binary_dir(a:target) . '/flags.make'

    if filereadable(l:flags_file)
      let flags = { 
        \ 'c'   : cmake#flags#collect(l:flags_file, 'C'),
        \ 'cpp' : cmake#flags#collect(l:flags_file, 'CXX')
        \ }
    endif
  endif

  return flags
endfunction!
