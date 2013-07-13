func! cmake#util#rootdir()
  if exists("g:cmake_current_binary_dir") && g:cmake_current_binary_dir != 0
    return g:cmake_current_binary_dir
  else
    let current_dir = getcwd()
    let items = split(current_dir, "/")

    for item in items
      let current_dir = cmake#util#find_cmake_build_dir(current_dir)

      if !len(items) | return 0 | endif

      if !isdirectory(current_dir)
        let current_dir = substitute(current_dir, "/" . item, "", "g")
        continue
      else
        let g:cmake_current_binary_dir = current_dir
        break
      endif

    endfor

  endif

  return g:cmake_current_binary_dir
endfunc

func! cmake#util#run_cmake(argstr)
  let l:dir = cmake#util#rootdir()
  if !isdirectory(l:dir)
    echoerr "[cmake] Can't find build directory."
    return 0
  else
    let l:command =  [ "cd", l:dir, "&&"]
    let l:command += [ "cmake", l:dir . "/.." ]
    let l:command += [ a:args ]
    let l:command += [ a:argstr ]
    let l:commandstr = join(l:command, " ")
    let l:output = system(l:commandstr)
    return l:output
  endif
endfunc

func! cmake#util#init_cmake()
  let l:dir = cmake#util#rootdir()
  if !isdirectory(l:dir)
    echoerr "[cmake] Can't find build directory."
    return 0
  else
    let l:command =  [ "-DCMAKE_INSTALL_PREFIX:FILEPATH="  . g:cmake_install_prefix ]
    let l:command += [ "-DCMAKE_BUILD_TYPE:STRING="        . g:cmake_build_type ]
    let l:command += [ "-DCMAKE_CXX_COMPILER:FILEPATH="    . g:cmake_cxx_compiler ]
    let l:command += [ "-DCMAKE_C_COMPILER:FILEPATH="      . g:cmake_c_compiler ] 
    let l:command += [ "-DBUILD_SHARED_LIBS:BOOL="         . g:cmake_build_shared_libs ]
    let l:commandstr = join(l:command, " ")
    return cmake#util#run_cmake(l:commandstr)
  endif
endfunc!

func! cmake#util#run_make(argstr)
  let l:dir = cmake#util#rootdir()
  if !isdirectory(l:dir)
    echoerr "[cmake] Can't find build directory."
    return 0
  else
    let l:output = system("make -C " . cmake#util#rootdir() . " " . a:argstr)
    return l:output
  endif
endfunc

func! cmake#util#find_cmake_build_dir(dir)
  if filereadable(a:dir . "/CMakeCache.txt")
    return a:dir
  else if len(g:cmake_build_dirs) != 0
    for folder in g:cmake_build_dirs
      if filereadable(a:dir . "/" . folder . "/CMakeCache.txt")
        echomsg "[cmake] " a.dir . "/" . folder
        return a:dir . "/" .folder
      else
        continue
      endif
    endfor
  endif

  return 0
endfunc
