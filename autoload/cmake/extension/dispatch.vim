" File:             autoload/cmake/extension/dispatch.vim
" Description:      vim-dispatch plugin for CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

func! cmake#extension#dispatch#sync(command)
  execute 'Dispatch "' . a:command . '"<CR>'
endfunc

func! cmake#extension#dispatch#async(command)
  execute 'Dispatch! "' . a:command . '"<CR>'
endfunc
