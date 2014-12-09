" File:             autoload/cmake/extension/syntastic.vim
" Description:      Syntastic plugin for CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

func! cmake#extension#syntastic#inject(args)
  let l:target = args['target']
  let l:include_dirs = cmake#targets#include_dirs(target)
  let l:flags = cmake#targets#flags(target)

  if exists('b:synastic_cpp_includes') || empty(b:synastic_cpp_includes)
    let b:synastic_cpp_includes = l:include_dirs
  endif
endfunc
