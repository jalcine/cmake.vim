" File:             autoload/cmake/extension/vimux.vim
" Description:      vimux plugin for CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.5

func! cmake#extension#vimux#sync(command)
  call VimuxRunCommand(a:command)
endfunc

func! cmake#extension#vimux#async(command)
  call VimuxRunCommand(a:command)
endfunc
