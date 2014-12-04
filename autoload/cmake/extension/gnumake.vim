" File:             autoload/cmake/extension/gnumake.vim
" Description:      Add GNU Make build support.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

function cmake#extension#gnumake#makeprg()
  return 'make -C {{root_build_directory}} {{target}}'
endfunction
