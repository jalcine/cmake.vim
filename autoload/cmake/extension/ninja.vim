" File:             autoload/cmake/extension/ninja.vim
" Description:      Add Ninja build support.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

function cmake#extension#ninja#makeprg()
  return 'ninja -C {{root_build_directory}} {{target}}'
endfunction

function cmake#extension#ninja#find_files_for_target(target)
  let l:files = []
  let l:bindir = cmake#util#binary_dir()
  let l:buildNinjaFile = resolve(l:bindir . '/build.ninja')

  if filereadable(l:buildNinjaFile)
    let l:files = s:parse_target_depends(l:buildNinjaFile, a:target)
  else
    call cmake#util#echo_msg("Can't find file " . l:buildNinjaFile)
  endif

  return l:files
endfunction

func! s:parse_target_depends(buildNinjaFile, target)
  let l:ninja_file_lines = readfile(a:buildNinjaFile)
  let l:start_build_point = index(l:ninja_file_lines,
        \ "Object build statements * target " . a:target, 0)
  let l:end_build_point = index(l:ninja_file_lines,
        \ "# =============")

  let l:lines_of_interest = l:ninja_file_lines[l:start_build_point : l:end_build_point]
  echo l:lines_of_interest
  let l:objects = filter(l:lines_of_interest, 'v:val =~ "build "')

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
  let l:object_path = split(a:object_path, ':')
  echo l:object_path
  echo split(l:object_path[1], ' ')[1]
  return l:object_path
endfunc
