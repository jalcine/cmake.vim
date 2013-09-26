" Variables in CMake are stored in the ${CMAKE_BINARY_DIR}/CMakeCache.txt 
" file. The variables themselves are stored in a format like the following:
" NAME:TEXT=VALUE.

func! cmake#variables#exists(variable)
  let l:val = cmake#util#read_from_cache(variable)
  return l:val != 0
endfunc!

func! cmake#variables#get(variable)
  if !cmake#variables#exists(a:variable)
    return 0
  endif

  return cmake#util#read_from_cache(a:variable)[1]
endfunc

func! cmake#variables#set(variableName,newVariableValue)
  if !cmake#variables#exists(a:variable)
    return 0
  endif

  cmake#util#write_to_cache(a:variable, a:newVariableValue)
endfunc!
