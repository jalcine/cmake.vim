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
  if g:cmake_filter_flags == 1
    let l:flags = copy(a:flags)
    if !empty(l:flags)
      call filter(flags, "s:sort_out_flags(v:val)")
    endif
  endif

  return l:flags
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

  if !exists('b:cmake_flags') && !empty(&l:ft)
    let flags = cmake#targets#flags(b:cmake_target)

    if !has_key(flags,&ft)
      let b:cmake_flags = []
      return
    endif

    let b:cmake_flags = flags[&ft]
  endif

  call cmake#flags#inject_to_ycm(b:cmake_target)
  call cmake#flags#inject_to_syntastic(b:cmake_target)
endfunc

function! cmake#flags#file_for_target(target)
  return cmake#targets#binary_dir(a:target) . '/flags.make'
endfunction

function! cmake#flags#inject_to_syntastic(target)
  if g:cmake_inject_flags.syntastic != 1 | return | endif

  let l:flags = cmake#targets#flags(a:target)
  for l:language in keys(l:flags)
    let {'g:syntastic_' . l:language . '_compiler_options'} = join(l:flags[l:language], ' ')
  endfor
endfunction!

function! cmake#flags#inject_to_ycm(target)
  if !exists('g:ycm_extra_conf_vim_data') || g:cmake_inject_flags.ycm == 0
    return 0
  endif

  let l:flags_to_inject = [
        \ 'b:cmake_binary_dir',
        \ 'b:cmake_root_binary_dir',
        \ 'b:cmake_flags']

  for flag in l:flags_to_inject
    if index(g:ycm_extra_conf_vim_data, flag) == -1 && exists(flag)
      let g:ycm_extra_conf_vim_data += [flag]
    endif
  endfor

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
endfunction!
