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

" TODO: Check if there was a failure of sorts on configuring.
func! cmake#commands#create_build(directory)
  if count(g:cmake_build_directories, a:directory) == 0
    echomsg "[cmake] You should add '" . a:directory . "' to 'g:cmake_build_directories so CMake will be able to find it in the future."
    return 0
  endif

  " Make the directory.
  if !isdirectory(a:directory)
    call mkdir(a:directory, "p")
  endif

  " Prepopulate options for new CMake build.
  let l:build_options = s:get_build_opts()

  " Make the build.
  echomsg "[cmake] Configuring project for the first time..."
  let l:output = system("cd " . getcwd() . "/" . a:directory . " && " .
        \ "cmake .. " . l:build_options)
  echomsg "[cmake] Project configured."
endfunc

func! s:get_build_opts()
  let l:command =  [ "-DCMAKE_INSTALL_PREFIX:FILEPATH="  . g:cmake_install_prefix ]
  let l:command += [ "-DCMAKE_BUILD_TYPE:STRING="        . g:cmake_build_type ]
  let l:command += [ "-DCMAKE_CXX_COMPILER:FILEPATH="    . g:cmake_cxx_compiler ]
  let l:command += [ "-DCMAKE_C_COMPILER:FILEPATH="      . g:cmake_c_compiler ] 
  "let l:command += [ "-DBUILD_SHARED_LIBS:BOOL="         . g:cmake_build_shared_libs ]
  let l:commandstr = join(l:command, " ")

  return l:commandstr
endfunc!
