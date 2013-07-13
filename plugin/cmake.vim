if !exists("g:cmake_plugin_loaded") 
  let g:cmake_plugin_loaded = 1

  " Set configuration options.
  if !exists("g:cmake_cxx_compiler")       |  let g:cmake_cxx_compiler      = "clang++"       |  endif
  if !exists("g:cmake_c_compiler")         |  let g:cmake_c_compiler        = "clang"         |  endif
  if !exists("g:cmake_build_dirs")         |  let g:cmake_build_dirs        = [ "build" ]     |  endif
  if !exists("g:cmake_build_type")         |  let g:cmake_build_type        = "Debug"         |  endif
  if !exists("g:cmake_install_prefix")     |  let g:cmake_install_prefix    = "$HOME/.local"  |  endif
  if !exists("g:cmake_build_shared_libs")  |  let g:cmake_build_shared_libs = 1               |  endif
  if !exists("g:cmake_set_makeprg")        |  let g:cmake_set_makeprg       = 1               |  endif

  " Set Ex commands.
  command! -buffer -nargs=0 CMakeBuild       :call cmake#commands#build()
  command! -buffer -nargs=0 CMakeInstall     :call cmake#commands#install()
  command! -buffer -nargs=0 CMakeClean       :call cmake#commands#install()
  command! -buffer -nargs=0 CMakeTest        :call cmake#commands#test()
  command! -buffer -nargs=0 CMakeCreateBuild :call cmake#commands#create_build()
  command! -buffer -nargs=0 CMakeDeleteBuild :call cmake#commands#delete_build()

  if g:cmake_set_makeprg == 1 && isdirectory(cmake#util#rootdir())
    let &mp="make -C " . cmake#util#rootdir()
  endif
endif
