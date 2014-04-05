" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.2

function! cmake#augroup#on_vim_enter()
  call cmake#commands#apply_global_commands()
  call cmake#flags#prep_ycm()
endfunc

function! cmake#augroup#on_buf_enter()
  call cmake#commands#apply_buffer_commands()
  call cmake#util#set_buffer_options()
  call cmake#util#apply_makeprg()
  call cmake#flags#inject()
endfunc

function! cmake#augroup#on_file_read_post()
  call cmake#path#refresh()
endfunc
