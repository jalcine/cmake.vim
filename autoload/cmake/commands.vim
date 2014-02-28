" File:             autoload/cmake/commands.vim
" Description:      The "API" of cmake.vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.2.2
" Last Modified:    2013-09-28 15:21:51 EDT

func! cmake#commands#build()
  echomsg "[cmake] Building all targets..."
  call cmake#util#run_cmake("--build", "","")
  echomsg "[cmake] Built all targets."
endfunc

func! cmake#commands#invoke_target(target)
  echomsg "[cmake] Invoking target '" . a:target . "'..."
  call cmake#util#run_cmake("--build ". cmake#util#binary_dir() . 
    \ " --target " . a:target. " --", "", "")
endfunc

func! cmake#commands#build_current()
  call cmake#commands#build_target_for_file(fnamemodify(bufname('%'), ':p'))
endfunc

func! cmake#commands#build_target_for_file(file)
  let target = cmake#targets#for_file(a:file)
  if empty(target)
    return 0
  endif

  echomsg "[cmake] Building target '" . l:target . "'..."
  call cmake#targets#build(target)
  echomsg "[cmake] Built target '" . l:target . "'."
endfunc

func! cmake#commands#clean()
  echomsg "[cmake] Cleaning build..."
  call cmake#util#run_make("clean")
  echomsg "[cmake] Cleaned build."
endfunc

func! cmake#commands#test()
  echomsg "[cmake] Testing build..."
  call cmake#util#run_make("test")
  echomsg "[cmake] Tested build."
endfunc

func! cmake#commands#rebuild_cache()
  echomsg "[cmake] Rebuilding cache for CMake.."
  call cmake#util#run_make("rebuild_cache")
  echomsg "[cmake] Rebuilt cache for CMake."
endfunc

func! cmake#commands#install()
  echomsg "[cmake] Installing project..."
  call cmake#util#run_make("install")
  echomsg "[cmake] Installed project."
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

function! cmake#commands#install_ex()
  if cmake#util#has_project() == 1
    command! -buffer -nargs=0 CMakeBuild
          \ :call cmake#commands#build()
    command! -buffer -nargs=0 CMakeRebuildCache
          \ :call cmake#commands#rebuild_cache()
    command! -buffer -nargs=0 CMakeClean
          \ :call cmake#commands#clean()
    command! -buffer -nargs=0 CMakeCleanBuild 
          \ :call s:clean_then_build()
    command! -buffer -nargs=0 CMakeTest
          \ :call cmake#commands#test()
    command! -buffer -nargs=0 CMakeInstall
          \ :call cmake#commands#install()
    command! -buffer -nargs=0 CMakeClearBufferOpts
          \ :unlet b:cmake_binary_dir
    command! -buffer -nargs=0 CMakeBuildCurrent
          \ :call cmake#commands#build_current()
    command! -buffer -nargs=1 -complete=customlist,s:get_targets
          \ CMakeTarget :call cmake#targets#build("<args>")
    command! -buffer -nargs=1 CMakeGetVar
          \ :echo cmake#commands#get_var("<args>")
  endif

  command -nargs=1 -complete=dir CMakeCreateBuild
        \ :call cmake#commands#create_build("<args>")
endfunc!

func! s:clean_then_build()
  call cmake#commands#clean()
  call cmake#commands#build()
endfunc

func! s:get_targets(A,L,P)
  return cmake#targets#list()
endfunc

func! s:get_build_opts()
  let l:command =  [ '-G "Unix Makefiles" ']
  let l:command += [ '-DCMAKE_EXPORT_COMPILE_COMMANDS=1']
  let l:command += [ '-DCMAKE_INSTALL_PREFIX:FILEPATH='  . g:cmake_install_prefix ]
  let l:command += [ '-DCMAKE_BUILD_TYPE:STRING='        . g:cmake_build_type ]
  let l:command += [ '-DCMAKE_CXX_COMPILER:FILEPATH='    . g:cmake_cxx_compiler ]
  let l:command += [ '-DCMAKE_C_COMPILER:FILEPATH='      . g:cmake_c_compiler ] 
  let l:command += [ '-DBUILD_SHARED_LIBS:BOOL='         . g:cmake_build_shared_libs ]
  let l:commandstr = join(l:command, ' ')

  return l:commandstr
endfunc!
