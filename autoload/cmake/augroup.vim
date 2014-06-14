" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.1

function! cmake#augroup#on_vim_enter()
  call cmake#commands#apply_global_commands()
  if !cmake#buffer#has_project() | return | endif
  redraw | echomsg "[cmake.vim] Caching build..."
  for aTarget in cmake#targets#list()
    for aFile in cmake#targets#files(aTarget)
      let g:cmake_cache.files[aFile] = aTarget
    endfor
  endfor
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
  call cmake#path#refresh()
  call cmake#ctags#refresh()
endfunc

function! cmake#augroup#init()
  augroup cmake.vim
    au!
    au BufRead  *.*pp :call cmake#augroup#on_buf_read()
    au BufEnter *.*pp :call cmake#augroup#on_buf_enter()
  augroup END
endfunction
