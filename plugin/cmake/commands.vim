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

func! cmake#commands#create_build()
  if !filereadable(getcwd() . "/CMakeLists.txt")
    echoerr "[cmake] No `CMakeLists.txt` found at " . getcwd()
    return 0
  endif

  if !isdirectory(cmake#util#find_cmake_build_dir(getcwd()))
    let l:buildir = getcwd() . "/" . g:cmake_build_dirs[0]
    let l:cmakecachefile = buildir . "/CMakeCache.txt"

    echo system("mkdir " . buildir)
    echo system("touch " . cmakecachefile)
    echomsg "[cmake] Configuring project..."
    echo cmake#util#run_cmake(" ")
    echomsg "[cmake] Created build."
  else 
    echoerr "[cmake] Found an existing project build."
    return 0
  endif

  return 1
endfunc
