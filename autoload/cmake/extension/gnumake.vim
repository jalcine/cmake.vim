" File:             autoload/cmake/extension/gnumake.vim
" Description:      Add GNU Make build support.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

function! s:parse_target_depends(dependInfoCMakeFilePath, target)
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:srcdir = cmake#targets#source_dir(a:target)
  let l:dependContents = readfile(a:dependInfoCMakeFilePath)
  let l:objects = filter(l:dependContents, 'v:val =~ "\.o\"$"')

  for object_path in objects
    let theIndex = index(objects,object_path)
    let theFixedPath = s:normalize_object_path(object_path, a:target)
    let l:objects[theIndex] = theFixedPath
  endfor

  call map(l:objects, 'fnamemodify(v:val, ":p:t")')
  return l:objects
endfunc

function! s:normalize_object_path(object_path, target)
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:srcdir = cmake#targets#source_dir(a:target)

  " TODO: Strip the surrounding whitespace.
  let l:object_path = substitute(a:object_path, '  "', '', '')
  let l:object_path = substitute(l:object_path, '"(\s+)$', '', '')
  let l:parts = split(l:object_path, '" "')
  return l:parts[0]
endfunc

function! s:normalize_target_name(object_old_name)
  let object_name = substitute(a:object_old_name, cmake#util#binary_dir(), "", "g")
  let object_name = substitute(object_name, "**CMakeFiles/", "", "g")
  let object_name = substitute(object_name, ".dir", "", "g")
  let object_name = fnamemodify(object_name, ":t:r")
  return object_name
endfunc

function! cmake#extension#gnumake#makeprg()
  return 'make -C {{root_build_directory}} {{target}}'
endfunction

function! cmake#extension#gnumake#find_libraries_for_target(target)
  let libraries = []
  let link_file = resolve(cmake#targets#binary_dir(a:target) . '/link.txt')
  let link_components = split(join(readfile(link_file), ' '), ' ')
  call filter(link_components, "stridx(v:val, '-l', 0) == 0")

  for library in link_components
    let l:library = substitute(library, "^-l", "", "")
    call add(libraries, l:library)
  endfor

  return libraries
endfunction

function! cmake#extension#gnumake#find_files_for_target(target)
  if !cmake#util#has_project()
    return []
  endif

  let l:files = []
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:dependInfoCMakeFile = resolve(l:bindir . '/DependInfo.cmake')

  if filereadable(l:dependInfoCMakeFile)
    let l:files = s:parse_target_depends(l:dependInfoCMakeFile, a:target)
  endif

  return l:files
endfunction

function! cmake#extension#gnumake#find_targets()
  if !cmake#util#has_project()
    return []
  endif

  let targets = []
  let dirs = glob(cmake#util#binary_dir() ."/**/CMakeFiles/*.dir", 0, 1)

  for target_name in dirs
    let target_name = s:normalize_target_name(target_name)
    call add(targets, target_name)
  endfor

  return targets
endfunction

function! cmake#extension#gnumake#find_flags_for_target(target)
  let l:flags_file = cmake#targets#binary_dir(a:target) . '/flags.make'

  let l:cpp_flags = split(system("grep 'CXX_FLAGS = ' " . l:flags_file .
    \ ' | cut -b ' . (strlen('CXX_FLAGS = ')) . '-'))
  let l:cpp_flags = cmake#flags#filter(l:cpp_flags)
  let l:cpp_defines = split(system("grep 'CXX_DEFINES = ' " . l:flags_file
    \ . ' | cut -b ' . (strlen('CXX_DEFINES = ')) . '-'))

  let l:c_flags = split(system("grep 'C_FLAGS = ' " . l:flags_file .
    \ ' | cut -b ' . (strlen('C_FLAGS = ')) . '-'))
  let l:c_flags = cmake#flags#filter(l:c_flags)
  let l:c_defines = split(system("grep 'C_DEFINES = ' " . l:flags_file
    \ . ' | cut -b ' . (strlen('C_DEFINES = ')) . '-'))

  let l:params = l:c_flags + 
        \ l:cpp_flags + 
        \ l:c_defines +
        \ l:cpp_defines
  return l:params
endfunction
