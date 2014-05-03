" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.2

function! cmake#cache#read(property)
  if cmake#buffer#has_project() == 0
    return 0
  endif

  let l:cmake_cache_file = cmake#cache#file_path()
  let l:property_width = strlen(a:property) + 2

  " First, grep out this property.
  " TODO: Do this using Vim's string methods to make it more portable.
  let l:property_line = system("grep -E \"^" . a:property . ":\" " 
    \ . l:cmake_cache_file)
  if empty(l:property_line)
    return 0
  endif

  " Chop down the response to size.
  " TODO: Do this using Vim's string methods to make it more portable.
  let l:property_meta_value = system("echo '" . l:property_line . "' | cut -b "
    \ . l:property_width . "-")

  " Split it in half to get the resulting value and its type.
  let l:property_fields = split(l:property_meta_value, "=", 1)
  let l:property_fields[1] = substitute(l:property_fields[1], "\n", "", "g")
  return l:property_fields[1]
endfunc

function! cmake#cache#write(property,value)
  call cmake#util#run_cmake('-D' . a:property . ':STRING=' .
    \ shellescape(a:value))
endfunc

function! cmake#cache#file_path()
  if cmake#buffer#has_project()
    return cmake#util#binary_dir() . "/CMakeCache.txt"
  endif

  return ""
endfunc
