" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.6

function! s:render_for_cpp()
  call cmake#buffer#set_options()
  call cmake#buffer#set_makeprg()
  call cmake#flags#inject()
  call cmake#ctags#refresh()
  call cmake#path#refresh()
endfunction

function! s:render_for_cmake()
  call cmake#buffer#set_options()
  call cmake#buffer#set_makeprg()
  call cmake#path#refresh()
endfunction

function! cmake#augroup#on_vim_enter()
  if !cmake#util#has_project() | return | endif
  call cmake#commands#apply_global_commands()
  call cmake#targets#cache()
endfunc

function cmake#augroup#on_file_type(filetype)
  if !cmake#buffer#has_project() | return | endif

  if (a:filetype == 'cpp')
    call s:render_for_cpp()
  else if (a:filetype == 'cmake')
    call s:render_for_cmake()
  endif
endfunction

function! cmake#augroup#init()
  augroup cmake.vim
    au!
    au FileType cpp   :call cmake#augroup#on_file_type('cpp')
    au FileType cmake :call cmake#augroup#on_file_type('cmake')
  augroup END
endfunction
