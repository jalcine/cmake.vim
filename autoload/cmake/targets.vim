" File:        autoload/cmake/targets.vim
" Description: Handles the logic of interacting with targets.
" Author:      Jacky Alciné <me@jalcine.me>
" License:     MIT
" Website:     https://jalcine.github.io/cmake.vim
" Version:     0.5.x

func! cmake#targets#build(target)
  return cmake#util#run_cmake("--build " . cmake#util#binary_dir() .
        \ " --target" . a:target, '', '')
endfunc!

func! cmake#targets#exists(target)
  return index(cmake#targets#list(), a:target) != -1
endfunc

func! cmake#targets#binary_dir(target)
  let l:root_binary_dir = cmake#util#binary_dir()
  let l:root_source_dir = cmake#util#source_dir()
  let l:bindir = finddir('CMakeFiles/' . a:target . '.dir', l:root_binary_dir . ';' . l:root_source_dir)
  let l:bindir = fnamemodify(l:bindir, ':p:h')

  if l:bindir == l:root_source_dir || l:bindir == l:root_binary_dir
    return ""
  endif

  return l:bindir
endfunc!

func! cmake#targets#source_dir(target)
  if index(cmake#targets#list(), a:target) == -1
    return ''
  endif

  let l:build_dir  = cmake#targets#binary_dir(a:target)
  let l:source_dir = ""

  if !isdirectory(l:build_dir)
    return l:source_dir
  endif

  let l:root_binary_dir = cmake#util#binary_dir()
  let l:root_source_dir = cmake#util#source_dir()
  let l:source_dir = l:build_dir
  let l:source_dir = substitute(l:source_dir, '/CMakeFiles/' . a:target . '.dir', '', '')
  let l:source_dir = substitute(l:source_dir, l:root_binary_dir, l:root_source_dir, '')
  let l:source_dir = resolve(fnamemodify(l:source_dir, ':p:h'))
  return l:source_dir
endfunc!

func! cmake#targets#include_dirs(target)
  let flags = cmake#targets#flags(a:target)
  let dirs = []

  for key in keys(flags)
    let includes = filter(copy(flags[key]), 'stridx(v:val, "-I") == 0')
    call map(includes, 'fnamemodify(substitute(v:val, "^-I", "", ""),":p:h")')
    let dirs += includes
  endfor

  return dirs
endfunc

func! cmake#targets#libraries(target)
  let libraries = []
  let link_file = resolve(cmake#targets#binary_dir(a:target) . '/link.txt')
  let link_components = split(join(readfile(link_file), ' '), ' ')
  call filter(link_components, "stridx(v:val, '-l', 0) == 0")

  for library in link_components
    let l:library = substitute(library, "^-l", "", "")
    call add(libraries, l:library)
  endfor

  return libraries
endfunc

func! cmake#targets#for_file(filepath)
  let l:filename = fnamemodify(a:filepath,':t')
  let l:basename = fnamemodify(a:filepath,':t:r')

  if has_key(g:cmake_cache.files, l:filename)
    return g:cmake_cache.files[l:filename]
  endif

  if has_key(g:cmake_cache.files, l:basename)
    return g:cmake_cache.files[l:basename]
  endif


  let l:targets = cmake#targets#list()
  if empty(l:targets)
    return ""
  endif

  let l:target = ''
  for aTarget in l:targets
    let files = cmake#targets#files(aTarget)
    if empty(files)
      continue
    endif

    call filter(files, 'strridx(v:val, l:filename) != -1')

    if len(files) != 0
      let l:target = aTarget
    endif
  endfor

  if empty(l:target)
    return ""
  endif

  let g:cmake_cache.files[l:filename] = l:target
  return l:target
endfunc!

func! cmake#targets#flags(target)
  let flags = { 'c' : [], 'cpp' : [] }

  if !cmake#targets#exists(a:target)
    return l:flags
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
  endif

  let g:cmake_cache.targets[a:target].flags = flags
  return g:cmake_cache.targets[a:target].flags
endfunc!

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
    let l:dependInfoCMakeFile = fnamemodify(l:bindir .
          \ '/DependInfo.cmake', ':p')

    if filereadable(l:dependInfoCMakeFile)
      let g:cmake_cache.targets[a:target].files +=
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
      let g:cmake_cache.files[fnamemodify(aFile, ':t:r')] = aTarget
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

  call map(l:objects, '(fnamemodify(v:val, ":p:t"))')
  return l:objects
endfunc

func! s:normalize_object_path(object_path, target)
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:srcdir = cmake#targets#source_dir(a:target)

  " TODO: Strip the surrounding whitespace.
  let l:object_path = substitute(a:object_path, '  "', '', '')
  let l:object_path = substitute(l:object_path, '"(\s+)$', '', '')
  let l:parts = split(l:object_path, '" "')
  return l:parts[0]
endfunc

func! s:normalize_target_name(object_old_name)
  let object_name = substitute(a:object_old_name, cmake#util#binary_dir(), "", "g")
  let object_name = substitute(object_name, "**CMakeFiles/", "", "g")
  let object_name = substitute(object_name, ".dir", "", "g")
  let object_name = fnamemodify(object_name, ":t:r")
  return object_name
endfunc
