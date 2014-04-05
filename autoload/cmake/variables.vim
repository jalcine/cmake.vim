" File:             autoload/cmake/variables.vim
" Description:      The "API" of interacting with variables in cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.2

func! cmake#variables#exists(variable)
  let l:val = cmake#util#read_from_cache(variable)
  return l:val != 0
endfunc!

func! cmake#variables#get(variable)
  if !cmake#variables#exists(a:variable)
    return 0
  endif

  return cmake#util#read_from_cache(a:variable)[1]
endfunc

func! cmake#variables#set(variableName,newVariableValue)
  if !cmake#variables#exists(a:variable)
    return 0
  endif

  cmake#util#write_to_cache(a:variable, a:newVariableValue)
endfunc!
