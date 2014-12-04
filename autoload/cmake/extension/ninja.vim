" File:             autoload/cmake/extension/ninja.vim
" Description:      Add Ninja build support.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

function cmake#extension#ninja#makeprg()
  return 'ninja -C {{root_build_directory}} {{target}}'
endfunction
