" File:             autoload/cmake/extension/ycm.vim
" Description:      YouCompleteMe plugin for CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

func! cmake#extension#ycm#inject(args)
  if !exists('g:ycm_extra_conf_vim_data')
    let g:ycm_extra_conf_vim_data=[]
  endif

  call add(g:ycm_extra_conf_vim_data, 'g:cmake_root_binary_dir')
endfunc
