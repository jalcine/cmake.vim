" File:        autoload/cmake/targets.vim
" Description: Handles the logic of interacting with targets.
" Author:      Jacky Alciné <me@jalcine.me>
" License:     MIT
" Website:     https://jalcine.github.io/cmake.vim
" Version:     0.4.1

function! cmake#targets#build(target)
  echomsg "[cmake] Building target '" . a:target . "'..."
  return cmake#util#run_cmake("--build . --target " . a:target . " -- ", "", "")
endfunction!

function! cmake#targets#exists(target)
  return index(cmake#targets#list(), a:target) != -1
endfunc

function! cmake#targets#binary_dir(target)
  let l:bindir = glob(cmake#util#binary_dir() . '/**/' . a:target . '.dir', 1)
  let l:bindir = resolve(fnamemodify(l:bindir, ':p'))
  return l:bindir
endfunction!

function! cmake#targets#source_dir(target)
  let l:build_dir  = fnamemodify(cmake#targets#binary_dir(a:target), ':p')
  let l:source_dir = ""
  if !isdirectory(l:build_dir) | return l:source_dir | endif
  let l:root_binary_dir = fnamemodify(cmake#util#binary_dir(), ':p')
  let l:root_source_dir = fnamemodify(cmake#util#source_dir(), ':p')

  let l:source_dir = fnamemodify(substitute(l:build_dir, l:root_binary_dir,
        \ l:root_source_dir, ""), ':p')
  let l:source_dir = fnamemodify(substitute(l:source_dir, "\/CMakeFiles\/" .
        \ a:target . ".dir\/", "", ""), ':p')
  let l:source_dir = resolve(l:source_dir)
  return l:source_dir
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
  let l:targets = cmake#targets#list()
  let l:filepath = fnamemodify(a:filepath,':p:.:r')
  if empty(l:targets) | return 0 | endif

  if has_key(g:cmake_cache.files,l:filepath)
    return g:cmake_cache.files[l:filepath]
  endif

  for target in l:targets
    let files = cmake#targets#files(target)
    if empty(files) | continue | endif
    call filter(files, "stridx(v:val,l:filepath,0) != -1")

    if len(files) != 0
      let g:cmake_cache.files[l:filepath] = l:target
    else | continue | endif
  endfor

  if !has_key(g:cmake_cache.files,l:filepath)
    return 0
  endif

  return g:cmake_cache.files[l:filepath]
endfunction!

function! cmake#targets#flags(target)
  let flags = { 'c' : [], 'cpp' : [] }
  
  if !cmake#targets#exists(a:target)
    return []
  endif

  if has_key(g:cmake_cache.targets, a:target) &&
        \ !empty(g:cmake_cache.targets[a:target].flags)
    return g:cmake_cache.targets[a:target].flags
  endif

  let l:flags_file = cmake#targets#binary_dir(a:target) . '/flags.make'

  if filereadable(l:flags_file)
    let flags = {
      \ 'c'   : cmake#flags#collect(l:flags_file, 'C'),
      \ 'cpp' : cmake#flags#collect(l:flags_file, 'CXX')
      \ }
    let g:cmake_cache.targets[a:target].flags = flags
  endif

  return g:cmake_cache.targets[a:target].flags
endfunction!

function! cmake#targets#list()
  if empty(g:cmake_cache.targets)
    let dirs = glob(cmake#util#binary_dir() ."**/*.dir", 0, 1)
    let targets = []

    for target_name in dirs
      let target_name = s:normalize_target_name(target_name)
      let targets = add(targets, target_name)
      let g:cmake_cache.targets[target_name] = { 'files' : [], 'flags' : [] }
    endfor
  endif

  return keys(g:cmake_cache.targets)
endfunc

function! cmake#targets#files(target)
  if !cmake#targets#exists(a:target) | return [] | endif

  if empty(g:cmake_cache.targets[a:target].files)
    let l:bindir = cmake#targets#binary_dir(a:target)
    let l:objects = []
    let l:dependInternal = fnamemodify(l:bindir . '/depend.internal', ':p')

    if filereadable(l:dependInternal)
      let g:cmake_cache.targets[a:target].files =
            \ s:parse_target_depends(l:dependInternal, a:target)
    endif
  endif

  return g:cmake_cache.targets[a:target].files
endfunction!

function! s:parse_target_depends(dependInternalFile, target)
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:srcdir = cmake#targets#source_dir(a:target)
  let l:objects = readfile(a:dependInternalFile)

  let l:objects = sort(filter(l:objects, 'v:val =~ ".o$"'))
  if empty(l:objects) | return [] | endif

  for object_path in objects
    let theIndex = index(objects,object_path)
    let theFixedPath = s:normalize_object_path(object_path, a:target)
    let l:objects[theIndex] = theFixedPath
  endfor

  call filter(l:objects, 'filereadable(v:val) == 1')
  call map(l:objects, 'simplify(fnamemodify(v:val, ":p:."))')
  return l:objects
endfunction

function s:normalize_object_path(object_path, target)
  let l:object_name = a:object_path
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:file_path = fnamemodify(l:object_name, ':p')
  let l:strippable_fields = [ fnamemodify(l:bindir, ':p:.'),
        \ '\.o$', 'CMakeFiles/', a:target . '\.dir/']

  for stripping_field in l:strippable_fields
    let l:object_name = substitute(l:object_name, stripping_field, '', 'g')
  endfor

  let l:object_name = substitute(l:object_name, '\/\/', '\/', 'g')
  let l:object_name = substitute(l:object_name, '__', '\.\.', 'g')
  let l:object_name = fnamemodify(l:object_name, ':p:.')

  if filereadable(simplify(cmake#util#binary_dir() . '/'. l:object_name))
    let l:object_name = simplify(cmake#util#binary_dir() . '/'. l:object_name)
  elseif filereadable(simplify(cmake#util#source_dir() . '/'. l:object_name))
    let l:object_name = simplify(cmake#util#source_dir() . '/'. l:object_name)
  endif

  return l:object_name
endfunction

function s:normalize_target_name(object_old_name)
  let object_name = substitute(a:object_old_name, cmake#util#binary_dir(), "", "g")
  let object_name = substitute(object_name, "**CMakeFiles/", "", "g")
  let object_name = substitute(object_name, ".dir", "", "g")
  let object_name = fnamemodify(object_name, ":t:r")
  return object_name
endfunction
