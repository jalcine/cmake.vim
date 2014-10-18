" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.6

function! cmake#cache#read(property)
  if cmake#buffer#has_project() == 0
    return ""
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
  if len(l:property_fields) == 2
    let l:property_fields[1] = substitute(l:property_fields[1], "\n", "", "g")
    return l:property_fields[1]
  else
    " Guess you're shit outta luck; CMake gave us some weird value.
    return ""
  end
endfunc

function! cmake#cache#write(property,value)
  call cmake#util#run_cmake('-D' . a:property . ':STRING="' .
        \ shellescape(a:value) . '"', cmake#util#binary_dir(),
        \ cmake#util#source_dir())
endfunc

function! cmake#cache#file_path()
  if exists('g:cmake_cache_file_path')
    return g:cmake_cache_file_path
  endif

  let l:bindir = cmake#util#binary_dir()
  if isdirectory(l:bindir)
    let g:cmake_cache_file_path = fnamemodify(l:bindir . 'CMakeCache.txt', ':p')
  endif

  return g:cmake_cache_file_path
endfunc
