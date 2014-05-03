" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.2-1

function! cmake#augroup#on_vim_enter()
  call cmake#commands#apply_global_commands()
endfunc

function! cmake#augroup#on_buf_read_post()
  if cmake#buffer#has_project()
    call cmake#buffer#set_options()
    call cmake#commands#apply_buffer_commands()
  endif
endfunction

function! cmake#augroup#on_buf_enter()
  if cmake#buffer#has_project()
    call cmake#buffer#set_options()
    call cmake#buffer#set_makeprg()
    call cmake#flags#inject()
    call cmake#path#refresh()
  endif
endfunc
