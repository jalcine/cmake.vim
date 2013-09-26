""""""""""""""""""""""""""""""""""""""""
" @author: Jacky Alciné <me@jalcine.me>
" @date:   2013-09-26 00:31:53 EDT
"
" Utility methods to manipulate CMake.
""""""""""""""""""""""""""""""""""""""""

func! cmake#util#binary_dir()
  " If we found it already, don't waste effort.
  if exists("g:cmake_binary_dir")
    return g:cmake_binary_dir
  endif

  let l:proposed_dir = 0

  " Check in the currenty directory as well.
  let l:directories = g:cmake_build_directories + [ getcwd() ]

  for directory in l:directories
    " TODO: Make paths absolute.
    let l:proposed_cmake_file = findfile(directory . "/CMakeCache.txt", ".;")

    if filereadable(l:proposed_cmake_file)
      " If we found it, drop off that CMakeCache.txt reference and cache the
      " value.
      let l:proposed_dir = substitute(l:proposed_cmake_file, "/CMakeCache.txt", "", "")
    endif
  endfor

  if l:proposed_dir != 0
    let l:proposed_dir = expand(l:proposed_dir, ':p')
  endif

  return l:proposed_dir
endfunc!

" TODO; Resolve path to absolute-ness.
func! cmake#util#source_dir()
  if cmake#util#binary_dir() == 0
    return ""
  endif

  return cmake#util#read_from_cache("Project_SOURCE_DIR")
endfunc!

func! cmake#util#cmake_cache_file_path()
  let l:dir = cmake#util#binary_dir()
  if isdirectory(l:dir)
    return l:dir . "/CMakeCache.txt"
  endif

  return ""
endfunc!

func! cmake#util#read_from_cache(property)
  let l:cmake_cache_file = cmake#util#cmake_cache_file_path()
  let l:property_width = strlen(a:property) + 2

  " If we can't find the cache file, then there's no point in trying to read
  " it.
  if !filereadable(cmake#util#cmake_cache_file_path())
    return ""
  endif

  " First, grep out this property.
  let l:property_line = system("grep -E \"^" . a:property . ":\" " . l:cmake_cache_file)
  if empty(l:property_line)
    return 0
  endif

  " Chop down the response to size.
  let l:property_meta_value = system("echo '" . l:property_line . "' | cut -b " . l:property_width . "-")

  " Split it in half to get the resulting value and its type.
  let l:property_fields = split(l:property_meta_value, "=", 1)
  let l:property_fields[1] = substitute(l:property_fields[1], "\n", "", "")
  let l:property_fields[1] = substitute(l:property_fields[1], "\n", "", "")

  return l:property_fields
endfunc!

func! cmake#util#write_to_cache(property,value)
  " TODO: Use 'sed'.
endfunc!

func! cmake#util#run_make(command)
  let l:command = "make -C " . cmake#util#binary_dir() . " " . a:command
  if g:cmake_use_vimux == 1 && g:loaded_vimux == 1
    call VimuxRunCommand(l:command)
  else
    return system(l:command)
  endif
endfunc!
