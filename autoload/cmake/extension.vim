" File:             autoload/cmake/extension.vim
" Description:      Basis of extensibility for the CMake plugin.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

" A lot of magic happening here; that magic behind interpolation.
func! s:get_default_ext(class, type)

  if index(cmake#extension#list(), l:val) != -1
    return l:val
  endif

  return ""
endfunc

func! cmake#extension#list()
  let l:extensions = split(globpath(&rtp,'autoload/cmake*/extension/*.vim'), "\n")
  let l:extensions = map(l:extensions, 'fnamemodify(v:val, ":t:r")')
  return l:extensions
endfunc

func! cmake#extension#default_func(suffix, function_name)
  let l:variable= 'g:cmake_' . a:suffix
  let l:extension='vim'

  if exists(l:variable)
    if has_key({l:variable}, a:function_name)
      let l:extension={l:variable}[a:function_name]
    endif
  endif

  return 'cmake#extension#' . l:extension . '#' . a:function_name
endfunc
