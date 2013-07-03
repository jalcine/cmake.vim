func! cmake#commands#build()
  " Build the KRAKEN!
  call cmake#util#run_make("all")
endfunc

func! cmake#commands#clean()
  " Clean your room.
  call cmake#util#run_make("clean")
endfunc

func! cmake#commands#test()
  call cmake#util#run_make("test")
endfunc

func! cmake#commands#install()
  call cmake#utils#run_make("install")
endfunc

func! cmake#commands#preconfigure()
  call cmake#utils#run_cmake(".. -DCMAKE_INSTALL_PREFIX=" . g:cmake_install_prefix . " -DCMAKE_BUILD_TYPE=" . g:cmake_build_type . " -DBUILD_SHARED_LIBS=" . g:cmake_build_shared_libs)
endfunc

func! cmake#commands#reconfigure()
  for folder in g:cmake_build_dirs
    if isdirectory(getcwd() . "/" . folder)
      system("rm -rv " . getcwd() . "/" . folder)
      break
    endif
  endfor

  cmake#commands#preconfigure()
endfunc

func! cmake#commands#create_build()
  if !filereadable(getcwd() . "/CMakeLists.txt")
    echoerr "[cmake] No `CMakeLists.txt` found at " . getcwd()
    return
  endif

  mkdir g:cmake_build_dirs[0]
  cd g:cmake_build_dirs
  cmake#commands#preconfigure()
endif
