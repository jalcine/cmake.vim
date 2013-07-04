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
    return
  endif
  
  if cmake#util#cmake_build_exists(getcwd())
    echoerr "[cmake] CMake project already exists here."
    return
  else
    let buildir = getcwd() . "/" . g:cmake_build_dirs[0]
    let cmakecachefile = buildir . "/CMakeCache.txt"
    exec "!mkdir" buildir "; touch" cmakecachefile
    echomsg "[cmake] Configuring project..."
    call cmake#util#run_cmake(" ")
    echomsg "[cmake] Project configured at '" . buildir . "'"
  endif
endfunc
