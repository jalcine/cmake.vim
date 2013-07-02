" Variables in CMake are stored in the ${CMAKE_BINARY_DIR}/CMakeCache.txt 
" file. The variables themselves are stored in a format like the following:
" NAME:TEXT=VALUE.

func! cmake#variables#exists(variable)
  let output = system("grep " . a:variable . " " . cmake#util#rootdir() . "/CMakeCache.txt")
  return strlen(output) > 0 ? 1 : 0
endfunc!

func! cmake#variables#get(variable)
  if !cmake#variables#exists(a:variable)
    return 0
  endif

  let output = system("grep " . a:variable . " " . cmake#util#rootdir() . "/CMakeCache.txt")
  return substitute(output, a:variable . "=", "", "g")
endfunc

func! cmake#variables#set(variableName,newVariableValue)
  if !cmake#variables#exists(a:variable)
    return 0
  endif
  " TODO: Grab cache data.
  " TODO: Set variable.
endfunc!
