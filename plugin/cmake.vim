" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.2.1
" Last Modified:    2013-09-28 19:32:47 EDT

" If we're here, don't reload man.
if exists("g:loaded_cmake") 
  finish
else
  let g:loaded_cmake = 1
end

func! s:setauto(name, value)
  if !exists(a:name)
    let {a:name} = a:value
  endif
endfunc

" Set configuration options.
let s:options = {
  \  "g:cmake_cxx_compiler":        "clang++",
  \  "g:cmake_c_compiler":          "clang",
  \  "g:cmake_build_directories":   [ "build"],
  \  "g:cmake_build_type":          "Debug",
  \  "g:cmake_install_prefix":      "/usr/local", 
  \  "g:cmake_build_shared_libs":   0,
  \  "g:cmake_set_makeprg":         1,
  \  "g:cmake_use_vimux":           exists("g:loaded_vimux"),
  \  "g:cmake_inject_flags":        {
      \ "syntastic":                exists("g:loaded_syntastic_plugin"),
      \ "ycm":                      exists("g:ycm_check_if_ycm_core_present")
      \ }
  \ }

for aOption in keys(s:options)
  call s:setauto(aOption, s:options[aOption])
endfor

function! s:set_ex_commands()
  " Set Ex commands.
  command! -nargs=0 CMakeBuild       :call cmake#commands#build()
  command! -nargs=0 CMakeClean       :call cmake#commands#clean()
  command! -nargs=0 CMakeCleanBuild  :call s:clean_then_build()
  command! -nargs=1 CMakeTarget      :call cmake#commands#invoke_target("<args>")
  command! -nargs=0 CMakeTest        :call cmake#commands#test()
  command! -nargs=0 CMakeInstall     :call cmake#commands#install()
  command! -nargs=1 CMakeCreateBuild :call cmake#commands#create_build("<args>")
  command! -nargs=1 CMakeGetVar      :echo cmake#commands#get_var("<args>")
endfunc!

func! s:clean_then_build()
  call cmake#commands#clean()
  call cmake#commands#build()
endfunc

call s:set_ex_commands()

" Set the command!
if exists("g:cmake_set_makeprg") && g:cmake_set_makeprg == 1
  let l:build_dir = cmake#util#binary_dir()
  if !empty(l:build_dir)
    set makeprg="make -C " . l:build_dir
  endif
endif
