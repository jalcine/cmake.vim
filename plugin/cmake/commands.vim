func! cmake#commands#build()
  echomsg "[cmake] Building target 'all'..."
  let l:output = cmake#util#run_make("all")
  echo l:output
endfunc

func! cmake#commands#clean()
  echomsg "[cmake] Cleaning..."
  call cmake#util#run_make("clean")
endfunc

func! cmake#commands#test()
  echomsg "[cmake] Running target 'test'..."
  call cmake#util#run_make("test")
endfunc

func! cmake#commands#install()
  echomsg "[cmake] Installing project..."
  call cmake#util#run_make("install")
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
    echo cmake#util#init_cmake()
    echomsg "[cmake] Created build."
  else 
    echoerr "[cmake] Found an existing project build."
    return 0
  endif
endfunc

func! cmake#commands#delete_build()
  if !filereadable(getcwd() . "/CMakeLists.txt")
    echoerr "[cmake] No `CMakeLists.txt` found at " .getcwd()
    return 0
  endif

  if isdirectory(cmake#util#find_cmake_build_dir(getcwd()))
    echo system("rm -rv" . cmake#util#find_cmake_build_dir(getcwd()))
  endif

  return 1
endfun
