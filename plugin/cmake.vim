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
  \  "g:cmake_set_makeprg":         0,
  \  "g:cmake_use_vimux":           0
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
