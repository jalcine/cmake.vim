" If we're here, don't reload man.
if exists("g:cmake_plugin_loaded") 
  finish
else
  let g:cmake_plugin_loaded = 1
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

" Set Ex commands.
command! -buffer -nargs=0 CMakeBuild       :call cmake#commands#build()
command! -buffer -nargs=0 CMakeInstall     :call cmake#commands#install()
command! -buffer -nargs=0 CMakeClean       :call cmake#commands#clean()
command! -buffer -nargs=0 CMakeTest        :call cmake#commands#test()
command! -buffer -nargs=1 CMakeCreateBuild :call cmake#commands#create_build("<args>")
