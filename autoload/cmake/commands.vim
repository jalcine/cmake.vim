func! cmake#commands#build()
  echomsg "[cmake] Building all targets..."
  let l:output = cmake#util#run_cmake("--build", "","")
  if l:output != 0
    echomsg l:output
    echomsg "[cmake] Built all targets."
  end
endfunc

func! cmake#commands#invoke_target(target)
  echomsg "[cmake] Invoking target '" . a:target . "'..."
  call cmake#util#run_cmake("--build ". cmake#util#binary_dir() . " --target " . a:target. " --", "", "")
endfunc

func! cmake#commands#clean()
  echomsg "[cmake] Cleaning build..."
  let l:output = cmake#util#run_make("clean")
  if l:output != 0
    echomsg l:output
  end
endfunc

func! cmake#commands#test()
  echomsg "[cmake] Testing build..."
  let l:output = cmake#util#run_make("test")
  if l:output != 0
    echomsg l:output
  end
endfunc

func! cmake#commands#install()
  echomsg "[cmake] Installing project..."
  let l:output = cmake#util#run_make("install")
  if l:output != 0
    echomsg l:output
  end
endfunc

" TODO: Check if there was a failure of sorts on configuring.
func! cmake#commands#create_build(directory)
  if count(g:cmake_build_directories, a:directory) == 0
    echomsg "[cmake] You should add '" . a:directory . "' to 'g:cmake_build_directories so CMake will be able to find it in the future."
    return 0
  endif

  " Make the directory.
  if filereadable(a:directory . "/CMakeCache.txt")
    if confirm("[cmake] Remove existing project configuration?", "&Yes\&No") == 1
      call delete(a:directory . '/CMakeCache.txt')
    else
      return
    endif
  endif

  if !isdirectory(a:directory)
    call mkdir(a:directory, "p")
  endif

  " Prepopulate options for new CMake build.
  let l:build_options = s:get_build_opts()

  " Make the build.
  echomsg "[cmake] Configuring project for the first time..."
  call cmake#util#run_cmake(l:build_options, getcwd() . "/" . a:directory, getcwd())
  echomsg "[cmake] Project configured."
endfunc


func! cmake#commands#get_var(variable)
  return cmake#util#read_from_cache(a:variable)
endfunc!

func! cmake#commands#set_var(variable,value)
  call cmake#util#write_to_cache(a:variable,a:value)
endfunc!

func! s:get_build_opts()
  let l:command =  [ '-G "Unix Makefiles" ']
  let l:command += [ "-DCMAKE_INSTALL_PREFIX:FILEPATH="  . g:cmake_install_prefix ]
  let l:command += [ "-DCMAKE_BUILD_TYPE:STRING="        . g:cmake_build_type ]
  let l:command += [ "-DCMAKE_CXX_COMPILER:FILEPATH="    . g:cmake_cxx_compiler ]
  let l:command += [ "-DCMAKE_C_COMPILER:FILEPATH="      . g:cmake_c_compiler ] 
  "let l:command += [ "-DBUILD_SHARED_LIBS:BOOL="         . g:cmake_build_shared_libs ]
  let l:commandstr = join(l:command, " ")

  return l:commandstr
endfunc!