" File:             autoload/cmake/flags.vim
" Description:      Handles the act of injecting flags into Vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.3.2

function! cmake#flags#filter(flags)
  if g:cmake_filter_flags == 0
    return a:flags
  endif

  let l:flags = copy(a:flags)
  if empty(l:flags)
    call filter(flags, "s:sort_out_flags(v:val)")
  endif

  return l:flags
endfunction!

function! s:sort_out_flags(val)
  echo "Flag: " . a:val
  if stridx(a:val, '-i') == 0
    return 1
  else if stridx(a:val, '-I') == 0
    return 1
  else if stridx(a:val, '-W') == 0
    return 1
  else if stridx(a:val, '-f') == 0
    return 1
  endif

  return 0
endfunction

function! cmake#flags#inject()
  let target = cmake#targets#for_file(fnamemodify(bufname('%'), ':p'))

  if empty(target)
    return
  endif

  " Set the flags for this current file.
  let b:cmake_flags = cmake#targets#flags(target)[&ft]

  " Do what is right.
  call cmake#flags#inject_to_ycm(target)
  call cmake#flags#inject_to_syntastic(target)
endfunc

function! cmake#flags#inject_to_syntastic(target)
  if g:cmake_inject_flags.syntastic != 1
    return
  endif

  let l:flags = cmake#targets#flags(a:target)
  if empty(l:flags)
    return
  endif

  for l:language in keys(l:flags)
    " TODO You got this.
  endfor
endfunction!

function! cmake#flags#inject_to_ycm(target)
  if g:cmake_inject_flags.ycm == 0
    return 0
  endif

  call cmake#flags#prep_ycm()

endfunc

function! cmake#flags#collect(flags_file, prefix)
  let l:flags = split(system("grep '" . a:prefix . "_FLAGS = ' " . a:flags_file . 
    \ ' | cut -b ' . (strlen(a:prefix) + strlen('_FLAGS = ')) . '-'))
  let l:flags = cmake#flags#filter(l:flags)

  let l:defines = split(system("grep '" . a:prefix . "_DEFINES = ' " . a:flags_file 
    \ . ' | cut -b ' . (strlen(a:prefix) + strlen('_DEFINES = ')) . '-'))

  let l:params = l:flags + l:defines
  return l:params
endfunction!

function! cmake#flags#prep_ycm()
  if g:cmake_inject_flags.ycm == 0
    return 0
  endif

  if index(g:ycm_extra_conf_vim_data, 'b:cmake_binary_dir') == -1 && 
      \ exists('b:cmake_binary_dir')
    let g:ycm_extra_conf_vim_data += ['b:cmake_binary_dir']
  endif
  if index(g:ycm_extra_conf_vim_data, 'b:cmake_root_binary_dir') == -1 && 
      \ exists('b:cmake_root_binary_dir')
    let g:ycm_extra_conf_vim_data += ['b:cmake_root_binary_dir']
  endif
  if index(g:ycm_extra_conf_vim_data, 'b:cmake_flags') == -1 &&
      \ exists('b:cmake_flags')
    let g:ycm_extra_conf_vim_data += ['b:cmake_flags']
  endif
endfunction!
