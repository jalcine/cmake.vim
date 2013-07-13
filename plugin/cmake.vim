func s:init_config()
  if !exists("g:cmake_cxx_compiler")
    let g:cmake_cxx_compiler = "clang++"
  endif

  if !exists("g:cmake_c_compiler")
    let g:cmake_c_compiler = "clang"
  endif

  if !exists("g:cmake_build_dirs")
    let g:cmake_build_dirs = [ "build" ]
  endif

  if !exists("g:cmake_build_type")
    let g:cmake_build_type = "Debug"
  endif

  if !exists("g:cmake_install_prefix")
    let g:cmake_install_prefix = "$HOME/.local"
  endif

  if !exists("g:cmake_build_shared_libs")
    let g:cmake_build_shared_libs = 1
  endif
endfunc

func s:init_commands()
  exe "command! -buffer -nargs=0 CMakeBuild :call cmake#commands#build()"
  exe "command! -buffer -nargs=0 CMakeInstall :call cmake#commands#install()"
  exe "command! -buffer -nargs=0 CMakeClean :call cmake#commands#install()"
  exe "command! -buffer -nargs=0 CMakeTest :call cmake#commands#test()"
  exe "command! -buffer -nargs=0 CMakeCreateBuild :call cmake#commands#create_build()"
  exe "command! -buffer -nargs=0 CMakeDeleteBuild :call cmake#commands#delete_build()"
endfunc

if !exists("b:cmake_loaded_plugin")
  let b:cmake_loaded_plugin
  call s:init_config()
  call s:init_commands()
endif
