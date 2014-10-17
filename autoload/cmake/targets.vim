" File:        autoload/cmake/targets.vim
" Description: Handles the logic of interacting with targets.
" Author:      Jacky Alciné <me@jalcine.me>
" License:     MIT
" Website:     https://jalcine.github.io/cmake.vim
" Version:     0.4.5

func! cmake#targets#build(target)
  call cmake#util#echo_msg("Building target '" . a:target . "'...")
  return cmake#util#run_cmake("--build . --target " . a:target . " -- ", "", "")
endfunc!

func! cmake#targets#exists(target)
  return index(cmake#targets#list(), a:target) != -1
endfunc

func! cmake#targets#binary_dir(target)
  let path_lookup = simplify(cmake#util#binary_dir() . '**/CMakeFiles/' . a:target . '*/')
  let paths_to_look_in = [ cmake#util#binary_dir(), cmake#util#source_dir() ]
  let l:bindir = glob(path_lookup, 1, 0)
  return bindir
  if len(l:bindir) == 0 | return '<none>' | endif
  let l:bindir = resolve(fnamemodify(l:bindir, ':p'))
  return l:bindir
endfunc!

func! cmake#targets#source_dir(target)
  if index(cmake#targets#list(), a:target) == -1 | return '' | endif
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
endfunc!

func! cmake#targets#include_dirs(target)
  let flags = cmake#targets#flags(a:target)
  let dirs = []

  if !empty(flags)
    for key in keys(flags)
      let includes = filter(copy(flags[key]), 'stridx(v:val, "-I") == 0')
      call map(includes, 'substitute(v:val, "^-I", "", "")')
      let dirs += includes
    endfor
  endif

  return dirs
endfunc

func! cmake#targets#libraries(target)
  return []
endfunc

func! cmake#targets#for_file(filepath)
  let l:targets = cmake#targets#list()
  if empty(l:targets) | return 0 | endif
  let l:target = ''
  let l:filepath = fnamemodify(a:filepath,':p:.:r')

  if has_key(g:cmake_cache.files,l:filepath)
    return g:cmake_cache.files[l:filepath]
  endif

  for aTarget in l:targets
    let files = cmake#targets#files(aTarget)
    if empty(files) | continue | endif
    call filter(files, 'strridx(v:val, l:filepath) != -1')

    if len(files) != 0
      let l:target = aTarget
    else | continue | endif
  endfor

  if empty(l:target) | return 0 | endif
  let g:cmake_cache.files[l:filepath] = l:target
  return l:target
endfunc!

func! cmake#targets#flags(target)
  let flags = { 'c' : [], 'cpp' : [] }

  if !cmake#targets#exists(a:target)
    return {
          \ 'c' : [],
          \ 'cpp' : []
          \ }
  endif

  if has_key(g:cmake_cache.targets, a:target) &&
        \ !empty(g:cmake_cache.targets[a:target].flags)
    return g:cmake_cache.targets[a:target].flags
  endif

  let l:flags_file = cmake#flags#file_for_target(a:target)

  if filereadable(l:flags_file)
    let flags = {
          \ 'c'   : cmake#flags#collect(l:flags_file, 'C'),
          \ 'cpp' : cmake#flags#collect(l:flags_file, 'CXX')
          \ }
    let g:cmake_cache.targets[a:target].flags = flags
  endif

  return g:cmake_cache.targets[a:target].flags
endfunc!

" TODO: Add option to load files here; warn about slower start.
" TODO: Add option to load flags here; warn about slower start.
func! cmake#targets#list()
  if empty(g:cmake_cache.targets)
    if !isdirectory(cmake#util#binary_dir()) | return [] | endif
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

func! cmake#targets#files(target)
  if !cmake#targets#exists(a:target) | return [] | endif

  if empty(g:cmake_cache.targets[a:target].files)
    let l:objects = []
    let l:bindir = cmake#targets#binary_dir(a:target)
    let l:dependInfoCMakeFile = fnamemodify(l:bindir . '/DependInfo.cmake', ':p')

    if filereadable(l:dependInfoCMakeFile)
      let g:cmake_cache.targets[a:target].files =
            \ s:parse_target_depends(l:dependInfoCMakeFile, a:target)
    endif
  endif

  return g:cmake_cache.targets[a:target].files
endfunc!

func! cmake#targets#cache()
  let theCount = 0
  for aTarget in cmake#targets#list()
    let files = cmake#targets#files(aTarget)

    if !len(files) | continue | endif

    for aFile in cmake#targets#files(aTarget)
      let g:cmake_cache.files[aFile] = aTarget
    endfor

    let theCount += len(files)
  endfor
endfunc

func! s:parse_target_depends(dependInfoCMakeFilePath, target)
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:srcdir = cmake#targets#source_dir(a:target)
  let l:objects = readfile(a:dependInfoCMakeFilePath)

  " Inside the `DependInfo.cmake` file for the project; pull out what we'd need
  " to pick out the sources for this specific target. This would be the lines
  " that has the source file mapping up to its respective object files.
  let l:objects = filter(l:objects, 'v:val =~ ".o\"$"')

  for object_path in objects
    let theIndex = index(objects,object_path)
    let theFixedPath = s:normalize_object_path(object_path, a:target)
    let l:objects[theIndex] = theFixedPath
  endfor
  return l:objects

  call filter(l:objects, 'filereadable(v:val) == 1')
  call map(l:objects, 'simplify(fnamemodify(v:val, ":p:."))')
  return l:objects
endfunc

func! s:normalize_object_path(object_path, target)
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:srcdir = cmake#targets#source_dir(a:target)

  " TODO: Strip the surrounding whitespace.
  let l:object_path = substitute(a:object_path, '  "', '', '')
  let l:object_path = substitute(l:object_path, '"(\s+)$', '', '')
  let l:parts = split(l:object_path, '" "')
  " TODO: Grab only the source file for now.
  
  return l:parts[0]
endfunc

func! s:normalize_target_name(object_old_name)
  let object_name = substitute(a:object_old_name, cmake#util#binary_dir(), "", "g")
  let object_name = substitute(object_name, "**CMakeFiles/", "", "g")
  let object_name = substitute(object_name, ".dir", "", "g")
  let object_name = fnamemodify(object_name, ":t:r")
  return object_name
endfunc
