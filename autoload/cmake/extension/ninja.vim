" File:             autoload/cmake/extension/ninja.vim
" Description:      Add Ninja build support.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

function! s:read_target_from_ninja(target)
  let l:bindir = cmake#util#binary_dir()
  let l:buildNinjaFile = fnamemodify(l:bindir . '/build.ninja', '%:p')
  let l:ninja_file_lines = readfile(l:buildNinjaFile)
  let l:start_build_point = match(l:ninja_file_lines,
        \ "target " . a:target, 0)
  let l:end_build_point = match(l:ninja_file_lines,
        \ "target " . a:target, l:start_build_point + 1)

  let l:lines_of_interest = l:ninja_file_lines[l:start_build_point : l:end_build_point]
  return l:lines_of_interest
endfunc

function! s:parse_target_files(target)
  let l:lines_of_interest = s:read_target_from_ninja(a:target)
  let l:objects = filter(l:lines_of_interest, 'v:val =~ "^build "')

  for object_path in objects
    let theIndex = index(objects,object_path)
    let theFixedPath = s:normalize_object_path(object_path, a:target)
    let l:objects[theIndex] = theFixedPath
  endfor

  call map(l:objects, '(fnamemodify(v:val, ":p:t"))')
  return l:objects
endfunc

function! s:parse_target_flags(target)
  let l:lines_of_interest = s:read_target_from_ninja(a:target)
  let l:flag_lines = filter(copy(l:lines_of_interest), 'v:val =~ "FLAGS ="')
  let l:defines_lines = filter(copy(l:lines_of_interest), 'v:val =~ "DEFINES ="')
  unlet l:lines_of_interest
  let l:flags = []
  let l:lines = l:flag_lines + l:defines_lines

  for flag_prop in lines
    let l:flags_str = split(l:flag_prop, ' = ')
    let l:flags += split(l:flags_str[1], ' ')
  endfor

  unlet l:lines
  call uniq(l:flags)
  return l:flags
endfunc

function! s:normalize_object_path(object_path, target)
  let l:bindir = cmake#targets#binary_dir(a:target)
  let l:srcdir = cmake#targets#source_dir(a:target)
  let l:object_path = split(split(a:object_path, ':')[1], ' ')[1]
  let l:object_path = l:object_path[3:]
  return l:object_path
endfunc

function! cmake#extension#ninja#makeprg()
  return 'ninja -C {{root_build_directory}} {{target}}'
endfunction

function! cmake#extension#ninja#find_flags_for_target(target)
  if !cmake#util#has_project() || !cmake#targets#exists(a:target)
    return []
  endif

  return s:parse_target_flags(a:target)
endfunction

function! cmake#extension#ninja#find_libraries_for_target(target)
  if !cmake#util#has_project() || !cmake#targets#exists(a:target)
    return []
  endif

  let l:bindir = cmake#util#binary_dir()
  let l:buildNinjaFile = fnamemodify(l:bindir . '/build.ninja', '%:p')
  let l:ninja_file_lines = readfile(l:buildNinjaFile)
  let l:ninja_working_lines = l:ninja_file_lines[:]
  call filter(l:ninja_file_lines, "v:val =~ 'Link build' ")
  call filter(l:ninja_file_lines, "v:val =~ 'target' ")
  call filter(l:ninja_file_lines, "v:val =~ '" . a:target . "' ")
  let l:start_index = index(l:ninja_working_lines, l:ninja_file_lines[0], 0)
  let l:end_index = match(l:ninja_working_lines, 'TARGET_PDB = ', l:start_index)
  let l:the_block = l:ninja_working_lines[l:start_index : l:end_index]
  call filter(l:the_block, "v:val =~ 'LINK_LIBRARIES = '")
  let l:libraries_string = split(l:the_block[0], ' = ')[1]

  unlet l:ninja_file_lines
  unlet l:ninja_working_lines

  let l:libraries = split(l:libraries_string, '-l')
  return l:libraries
endfunction

function! cmake#extension#ninja#find_files_for_target(target)
  if !cmake#util#has_project() || !cmake#targets#exists(a:target)
    return []
  endif

  let l:files = s:parse_target_files(a:target)
  return l:files
endfunction

function! cmake#extension#ninja#find_targets()
  if !cmake#util#has_project()
    return []
  endif

  let l:bindir = cmake#util#binary_dir()
  let l:buildNinjaFile = fnamemodify(l:bindir . '/build.ninja', '%:p')
  let l:ninja_file_lines = readfile(l:buildNinjaFile)
  let l:targets = []
  call filter(l:ninja_file_lines, "v:val =~ 'build' ")
  call filter(l:ninja_file_lines, "v:val =~ 'target' ")
  call map(l:ninja_file_lines, "split(v:val, ' ')[-1]")
  call uniq(l:ninja_file_lines)

  for target in l:ninja_file_lines
    call add(targets, target)
  endfor

  unlet l:ninja_file_lines
  return l:targets
endfunction
