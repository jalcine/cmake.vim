" File:             autoload/cmake/augroup.vim
" Description:      Handles the auto loading functionality of CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.5

function s:add_specific_buffer_commands()
  augroup cmake.vim
    au! BufEnter <buffer>
    au! BufWrite <buffer>
    au BufEnter <buffer> call cmake#augroup#on_buf_enter()
    au BufWrite <buffer> call cmake#augroup#on_buf_write()
  augroup END
endfunction

function! cmake#augroup#init()
  augroup cmake.vim
    au!
    au VimEnter      *  call cmake#augroup#on_vim_enter()
    au FileWritePost *  call cmake#augroup#on_file_write()
    au FileType      *  call cmake#augroup#on_file_type("<amatch>")
  augroup END
endfunction

function! cmake#augroup#on_vim_enter()
  if &diff
    " We don't want cmake.vim doing any work in diff mode, it slows things down.
  endif
  " NOTE: This function should handle the initial loading of cmake.vim's
  " necessary data in order for it to operate properly. This includes the
  " following:
  "   * checking if $PWD is a CMake project directory.
  "     - If there isn't any, bail out at this point.
  "   * priming the cache `g:cmake_cache`for future use.
  "   * adding global commands that would useful in creating a new CMake
  "     project.
  call cmake#targets#cache()
  call cmake#commands#apply()
endfunction

function! cmake#augroup#on_buf_enter()
  call cmake#util#echo_msg('Refreshing local buffer variables & options...')
  call cmake#buffer#set_options()
  call cmake#path#refresh()
  call cmake#makeprg#set_for_buffer()
  call cmake#util#echo_msg('Local buffer variables & options refreshed.')
endfunction

function! cmake#augroup#on_file_type(filetype)
  if !cmake#buffer#has_project()
    return
  endif

  call cmake#buffer#set_options()
  call cmake#ctags#refresh()

  if exists('b:cmake_target')
    call cmake#flags#inject()
  endif

  call s:add_specific_buffer_commands()
  redraw
endfunction

function! cmake#augroup#on_buf_write()
  call cmake#ctags#refresh()
endfunction

function! cmake#augroup#on_file_write()
  if exists('b:cmake_target')
    call cmake#targets#clear(b:cmake_target)
  endif

  call cmake#targets#cache()
endfunction
