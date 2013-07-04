func! cmake#util#rootdir()
  " We need to find the folder at which the file `CMakeCache.txt` can be 
  " found. Hopefully we don't have to transverse up the tree too far to find 
  " it. We'd start from the current working directory and begin to work 
  " our way up. Using some of the names of folders to include in a search like 
  " `build`, `bin`, etc would help sharpen the search.

  let current_dir = getcwd()
  while 1
    let dir = cmake#util#cmake_build_exists(current_dir)
    if dir
      let l:cmake_current_binary_dir = dir
      break
    else
      let items = split(current_dir, "/")
      if !len(items)
        " Looks like we hit the top of the tree.
        return 0
      endif

      let current_dir = substitute(current_dir, "/" . items[-1], "", "g")
      continue
    endif

  endwhile
  return l:cmake_current_binary_dir
endfunc

func! cmake#util#run_cmake(argstr)
  " To make life SO much easier for us, we'd just execute CMake in a wrapped 
  " call. It'd be nice to just grab stuff.
  exec "!clear; cd " . cmake#util#rootdir() ."; cmake . -DCMAKE_INSTALL_PREFIX:FILEPATH=" . g:cmake_install_prefix . " -DCMAKE_BUILD_TYPE:STRING=" . g:cmake_build_type . " -DBUILD_SHARED_LIBS:BOOL=" . g:cmake_build_shared_libs . " " .a:argstr
endfunc

func! cmake#util#run_make(argstr)
  " To make life SO much easier for us, we'd just execute CMake in a wrapped 
  " call. It'd be nice to just grab stuff.
  let l:output = system("make -C " . cmake#util#rootdir() . " " . a:argstr)
  return l:output
endfunc

" TODO: Refactor this method, it's possible.
func! cmake#util#cmake_build_exists(dir)
  if filereadable(a:dir . "/CMakeCache.txt")
    return a:dir
  else
    for folder in g:cmake_build_dirs
      if filereadable(a:dir . "/" . folder . "/CMakeCache.txt")
        return a:dir . "/" . folder
      endif
    endfor
  endif

  return 0
endfunc
