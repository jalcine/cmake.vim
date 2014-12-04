" File:        autoload/cmake/makeprg.vim
" Description: Logic for handling the 'makeprg' command in Vim.
" Author:      Jacky Alciné <me@jalcine.me>
" License:     MIT
" Website:     https://jalcine.github.io/cmake.vim
" Version:     0.5.x

function cmake#makeprg#for_target(target)
  let l:extension = cmake#extension#default_func('build_toolchain', 'makeprg')
  let l:makeprg_cmd = {l:extension}()

  let l:makeprg_cmd = substitute(l:makeprg_cmd, '{{target}}', a:target, 'g')
  let l:makeprg_cmd = substitute(l:makeprg_cmd, '{{target_build_directory}}', cmake#targets#binary_dir(a:target), 'g')
  let l:makeprg_cmd = substitute(l:makeprg_cmd, '{{root_build_directory}}', cmake#util#binary_dir(), 'g')

  return l:makeprg_cmd
endfunction

function cmake#makeprg#set_for_buffer()
  if exists('b:cmake_target') && !empty(b:cmake_target)
    let &l:makeprg = cmake#makeprg#for_target(b:cmake_target)
  else
    let &l:makeprg=""
  endif
endfunction
