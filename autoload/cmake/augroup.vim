" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.1

func! cmake#augroup#on_vim_enter()
  call cmake#commands#apply_global_commands()
endfunc

func! cmake#augroup#on_buf_enter()
  call cmake#flags#inject()
  call cmake#util#apply_makeprg()
  call cmake#commands#apply_buffer_commands()
endfunc

func! cmake#augroup#on_file_read_post()
  call cmake#path#refresh()
endfunc


