" File:             autoload/cmake/extension/gnumake.vim
" Description:      Add GNU Make build support.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

function cmake#extension#gnumake#makeprg()
  return 'make -C {{root_build_directory}} {{target}}'
endfunction

function cmake#extension#gnumake#find_files_for_target(target)
  let l:files = []
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:dependInfoCMakeFile = resolve(l:bindir .
        \ '/DependInfo.cmake')

  if filereadable(l:dependInfoCMakeFile)
    let l:files = s:parse_target_depends(l:dependInfoCMakeFile, a:target)
  endif

  return l:files
endfunction

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
