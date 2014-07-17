" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.2

function! cmake#augroup#on_vim_enter()
  call cmake#commands#apply_global_commands()

  if !cmake#util#has_project() | return | endif
  call cmake#util#echo_msg('Caching build...')
  call cmake#targets#cache()
  call cmake#util#echo_msg('Project cached into cmake.vim.')
endfunc

function! cmake#augroup#on_buf_read()
  if !cmake#buffer#has_project() | return | endif
  call cmake#buffer#set_options()
  call cmake#commands#apply_buffer_commands()
endfunction

function! cmake#augroup#on_buf_enter()
  if !cmake#buffer#has_project() | return | endif
  call cmake#buffer#set_makeprg()
  call cmake#flags#inject()
  call cmake#ctags#refresh()
  call cmake#path#refresh()
endfunc

function! cmake#augroup#init()
  augroup cmake.vim
    au!
    au BufEnter    *.*pp :call cmake#augroup#on_buf_enter()
    au BufReadPost *.*pp :call cmake#augroup#on_buf_read()
  augroup END
endfunction
