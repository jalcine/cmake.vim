" File:        autoload/cmake/makeprg.vim
" Description: Logic for handling the 'makeprg' command in Vim.
" Author:      Jacky Alciné <me@jalcine.me>
" License:     MIT
" Website:     https://jalcine.github.io/cmake.vim
" Version:     0.5.x

function cmake#makeprg#for_target(target)
  if !cmake#targets#exists(a:target)
    return ""
  endif

  let l:extension = cmake#extension#default_func('build_toolchain', 'makeprg')
  let l:makeprg_cmd = {l:extension}()

  let replacements = {
    \ 'target' : a:target,
    \ 'target_build_directory' : cmake#targets#binary_dir(a:target),
    \ 'root_build_directory': cmake#util#binary_dir()
    \ }

  for [ placeholder, value] in items(replacements)
    let l:makeprg_cmd = substitute(l:makeprg_cmd, '{{' . placeholder . '}}', value, 'g')
    unlet placeholder
    unlet value
  endfor

  return l:makeprg_cmd
endfunction

function cmake#makeprg#set_for_buffer()
  if exists('b:cmake_target') && !empty(b:cmake_target)
    let &l:makeprg = cmake#makeprg#for_target(b:cmake_target)
  else
    let &l:makeprg=""
  endif
endfunction
