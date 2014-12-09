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

func! cmake#extension#init()
  run! autoload/cmake/extension/*.vim
endfunc

func! cmake#extension#list()
  let l:exts = split(globpath(&rtp,'autoload/cmake/extension/*.vim'), "\n")
  let l:exts = map(l:exts, 'fnamemodify(v:val, ":t:r")')
  return l:exts
endfunc

func! cmake#extension#function_for(func, ext)
  let l:ext='vim'
  let l:signature='cmake#extension'

  if !empty(a:ext)
    let l:ext=a:ext
  endif

  let l:signature .= '#' . l:ext . '#' . a:func
  if !exists('*' . l:signature)
    let l:signature=""
  endif

  return l:signature
endfunc

func! cmake#extension#functions_for(func)
  let l:signatures=[]
  for ext in cmake#extension#list()
    call add(l:signatures, cmake#extension#function_for(a:func, ext))
  endfor

  call uniq(l:signatures)
  call filter(l:signatures, "v:val != ''")
  return l:signatures
endfunc

func! cmake#extension#flex(options)
  let l:functions = cmake#extension#functions_for('inject')
  for function in l:functions
    call {l:function}(a:options)
  endfor
endfunc
