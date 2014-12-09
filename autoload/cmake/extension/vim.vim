" File:             autoload/cmake/extension/vim.vim
" Description:      Default extension for CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

func! cmake#extension#vim#sync(command)
  let l:output = system(a:command)
  return l:output
endfunc

func! cmake#extension#vim#async(command)
  execute '!' . a:command
endfunc
