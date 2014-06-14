" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.4.1

" If we're here, don't reload man.
if exists("g:loaded_cmake")
  finish
else
  let g:loaded_cmake = 1
end

" Capture the user's predefined 'path'.
let g:cmake_old_path = &path

" Define the cache!
let g:cmake_cache = {
  \ 'targets' : {},
  \ 'files' : {}
  \ }

func! s:set_options()
  let s:options = {
  \  'g:cmake_cxx_compiler':      'clang++',
  \  'g:cmake_c_compiler':        'clang',
  \  'g:cmake_build_directories': [ 'build' ],
  \  'g:cmake_build_type':        'Debug',
  \  'g:cmake_install_prefix':    '/usr/local',
  \  'g:cmake_build_shared_libs': 1,
  \  'g:cmake_ctags':             {
  \     'project_files':          1,
  \     'include_files':          0,
  \     'executable':             'ctags'
  \   },
  \  'g:cmake_set_makeprg':       1,
  \  'g:cmake_use_dispatch':      exists('g:loaded_dispatch'),
  \  'g:cmake_filter_flags':      1,
  \  'g:cmake_inject_flags':      {
  \     'syntastic':              exists('g:loaded_syntastic_plugin'),
  \     'ycm':                    exists('g:ycm_check_if_ycm_core_present')
  \   }
  \ }
  for aOption in keys(s:options)
    call s:setauto(aOption, s:options[aOption])
  endfor
endfunc

func! s:setauto(name, value)
  if !exists(a:name)
    let {a:name} = a:value
  endif
endfunc

call s:set_options()
call cmake#augroup#init()
call cmake#augroup#on_vim_enter()
