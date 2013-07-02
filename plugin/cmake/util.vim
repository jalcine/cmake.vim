func! cmake#util#rootdir()
  " We need to find the folder at which the file `CMakeCache.txt` can be 
  " found. Hopefully we don't have to transverse up the tree too far to find 
  " it. We'd start from the current working directory and begin to work 
  " our way up. Using some of the names of folders to include in a search like 
  " `build`, `bin`, etc would help sharpen the search.

  " A wise man never repeats oneself.
  if exists("g:cmake_current_binary_dir")
    return g:cmake_current_binary_dir
  else
    let current_dir = getcwd()
    while 1
      if filereadable(current_dir . "/CMakeCache.txt")
        let g:cmake_current_binary_dir = current_dir
        break
      elseif exists("g:cmake_build_dirs")
        " Before we move up to the east side of Harlem, check out what the 
        " user might have wanted us to look for.
        for folder in g:cmake_build_dirs
          if filereadable(current_dir . "/" . folder . "/CMakeCache.txt")
            " WE FOUND IT!
            let g:cmake_current_binary_dir = current_dir . "/" . folder
            break
          else
            continue
          endif
        endfor
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
  endif

  echo g:cmake_current_binary_dir
  return g:cmake_current_binary_dir
endfunc

func! cmake#util#run_cmake(argstr)
  " To make life SO much easier for us, we'd just execute CMake in a wrapped 
  " call. It'd be nice to just grab stuff.
  let oldcwd = getcwd()
  let l:output = system("clear && cd " . cmake#util#rootdir() . " && cmake . " . a:argstr)
  cd oldcwd
  return l:output
endfunc

func! cmake#util#run_make(argstr)
  " To make life SO much easier for us, we'd just execute CMake in a wrapped 
  " call. It'd be nice to just grab stuff.
  let l:output = system("make -C " . cmake#util#rootdir() . " " . a:argstr)
  return l:output
endfunc
