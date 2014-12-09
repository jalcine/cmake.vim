" File:             autoload/cmake/flags.vim
" Description:      Handles the act of injecting flags into Vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.5

function! s:sort_out_flags(val)
  for a_good_flag in ['-i', '-I', '-W', '-f']
    if stridx(a:val, a_good_flag, 0) == 0
      return 1
    endif
  endfor
  return 0
endfunction

function! cmake#flags#filter(flags)
  let l:flags = []
  if g:cmake_flags.filter == 1
    let l:flags = copy(a:flags)
    if !empty(l:flags)
      call filter(flags, "s:sort_out_flags(v:val)")
    endif
  endif

  return l:flags
endfunction!

function! cmake#flags#collect_for_target(target)
  if !cmake#util#has_project()
    return []
  endif

  if !cmake#targets#exists(a:target)
    return []
  endif

  let l:flags_lookup = cmake#extension#function_for('find_flags_for_target', g:cmake_build_toolchain)
  let l:flags = {l:flags_lookup}(a:target)
  return l:flags
endfunction!

function! cmake#flags#inject()
  if !cmake#buffer#has_project() || exists('b:cmake_flags')
    return
  endif

  let flags = cmake#targets#flags(b:cmake_target)
  let b:cmake_flags = flags
endfunc
