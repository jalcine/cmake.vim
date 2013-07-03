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

  " TODO: Create a buildir
  " TODO: Go into said dir
  " TODO: Run inital CMake config.

  if cmake#util#cmake_build_exists(getcwd())
    echoerr "[cmake] CMake project already exists here."
    return
  else
    let buildir = getcwd() . "/" . g:cmake_build_dirs[0]
    call system("mkdir " . buildir)
    echomsg "[cmake] Configuring project..."
    exec "!cd " . buildir ."; cmake .. -DCMAKE_INSTALL_PREFIX=" . g:cmake_install_prefix
    echomsg "[cmake] Project configured at '" . buildir . "'"
  endif
endfunc
