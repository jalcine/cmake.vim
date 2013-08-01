func! cmake#commands#build()
  echomsg "[cmake] Building all targets..."
  let l:output = cmake#util#run_make("all")
  echo l:output
endfunc

func! cmake#commands#clean()
  echomsg "[cmake] Cleaning..."
  let l:output = cmake#util#run_make("clean")
  echo l:output
endfunc

func! cmake#commands#test()
  echomsg "[cmake] Testing project..."
  let l:output = cmake#util#run_make("test")
  echo l:output
endfunc

func! cmake#commands#install()
  echomsg "[cmake] Installing project..."
  let l:output = cmake#util#run_make("install")
  echo l:output
endfunc

func! cmake#commands#create_build()
  if !isdirectory(cmake#util#root_dir())
    echoerr "[cmake] Cannot find `CMakeLists.txt` in '" . getcwd() . "'."
    return 0
  endif

	if !isdirectory(cmake#util#find_cmake_build_dir(cmake#util#root_dir()))
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
