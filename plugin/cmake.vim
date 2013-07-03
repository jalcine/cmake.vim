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

" Define the commands for CMake to be used.
" TODO: Restrict this to only CMake formatted files?
" TODO: Implement commands that'd return text for variables.
exe "command! -buffer -nargs=0 CMakeBuild :call cmake#commands#build()"
exe "command! -buffer -nargs=0 CMakeInstall :call cmake#commands#install()"
exe "command! -buffer -nargs=0 CMakeClean :call cmake#commands#install()"
exe "command! -buffer -nargs=0 CMakeTest :call cmake#commands#test()"
