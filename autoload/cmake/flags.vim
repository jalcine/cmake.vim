" File:             autoload/cmake/flags.vim
" Description:      Handles the act of injecting flags into Vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.5

function! cmake#flags#file_for_target(target)
  return cmake#targets#binary_dir(a:target) . '/flags.make'
endfunction

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

function! cmake#flags#collect(flags_file, prefix)
  let l:flags = split(system("grep '" . a:prefix . "_FLAGS = ' " . a:flags_file .
    \ ' | cut -b ' . (strlen(a:prefix) + strlen('_FLAGS = ')) . '-'))
  let l:flags = cmake#flags#filter(l:flags)

  let l:defines = split(system("grep '" . a:prefix . "_DEFINES = ' " . a:flags_file
    \ . ' | cut -b ' . (strlen(a:prefix) + strlen('_DEFINES = ')) . '-'))

  let l:params = l:flags + l:defines
  return l:params
endfunction!

function! cmake#flags#inject()
  if !exists('b:cmake_target')
    let b:cmake_target = cmake#targets#for_file(expand('%:p:h'))
    if b:cmake_target == 0
      return
    else
      let target = b:cmake_target
    endif
  endif

  if !exists('b:cmake_flags')
    let flags = cmake#targets#flags(b:cmake_target)

    if !has_key(flags,&ft)
      let b:cmake_flags = []
      return
    endif

    let b:cmake_flags = flags[&ft]
  endif
endfunc

