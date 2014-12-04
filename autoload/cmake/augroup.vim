" File:             autoload/cmake/augroup.vim
" Description:      Handles the auto loading functionality of CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

function s:add_specific_buffer_commands()
  call cmake#commands#apply_buffer_commands()
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
    au VimEnter      *          call cmake#augroup#on_vim_enter()
    au FileReadPost  *          call cmake#augroup#on_file_read(fnamemodify("<afile>",":p"))
    au FileType      cpp,cmake  call cmake#augroup#on_file_type("<amatch>")
  augroup END
endfunction

function! cmake#augroup#on_vim_enter()
  " NOTE: This function should handle the initial loading of cmake.vim's
  " necessary data in order for it to operate properly. This includes the
  " following:
  "   * checking if $PWD is a CMake project directory.
  "     - If there isn't any, bail out at this point.
  "   * priming the cache `g:cmake_cache`for future use.
  "   * adding global commands that would useful in creating a new CMake
  "     project.
  call cmake#targets#cache()
endfunction

function! cmake#augroup#on_buf_enter()
  call cmake#util#echo_msg('Applying generic buffer options for this buffer...')
  call cmake#buffer#set_options()

  call cmake#util#echo_msg('Applying values for "&l:path"...')
  call cmake#path#refresh()

  call cmake#util#echo_msg('Applying values for "&l:makeprg"...')
  call cmake#makeprg#set_for_buffer()
endfunction

function! cmake#augroup#on_file_type(filetype)
  call cmake#util#echo_msg('Applying generic buffer options for this buffer...')
  call cmake#buffer#set_options()

  if !exists('b:cmake_target')
    call cmake#util#echo_msg('No target found for this buffer.')
    return
  endif

  call cmake#util#echo_msg('Applying values for "&l:makeprg"...')
  call cmake#makeprg#set_for_buffer()

  call cmake#util#echo_msg('Applying values for "&path"...')
  call cmake#path#refresh()

  call cmake#util#echo_msg('Applying values for "&tags" (will generate if not existing)...')
  call cmake#ctags#refresh()

  call cmake#util#echo_msg('Applying values for "&flags"....')
  call cmake#flags#inject()

  call s:add_specific_buffer_commands()
  doau BufEnter <abuf>
endfunction

function! cmake#augroup#on_buf_write()
  call cmake#util#echo_msg('Applying values for "&tags" (will generate if not existing)...')
  call cmake#ctags#refresh()
endfunction
