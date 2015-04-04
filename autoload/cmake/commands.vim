" File:             autoload/cmake/commands.vim
" Description:      The API of 'cmake.vim'.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.5

function! cmake#commands#build()
  call cmake#util#echo_msg('Building all targets...')
  call cmake#commands#invoke_target('all')
  call cmake#util#echo_msg('Built all targets.')
endfunc

func! cmake#commands#discover_project()
  " TODO: Look for the binary directory in the current directory.
endfunc

function! cmake#commands#invoke_target(target)
  call cmake#util#echo_msg("Invoking target '" . a:target . "'...")
  let l:output = cmake#util#run_cmake('--build ' . cmake#util#binary_dir() . ' --target ' . a:target)
  " TODO: Put output in quickfix.
endfunc

function! cmake#commands#build_current()
  if exists('b:cmake_target')
    call cmake#commands#invoke_target(b:cmake_target)
  else
    if cmake#buffer#has_project()
      call cmake#commands#invoke_target('all')
    else
      call cmake#util#echo_msg('This buffer does not live in a CMake project.')
    end
  endif
endfunc

function! cmake#commands#clear_ctags()
  let l:targets = cmake#targets#list()
  for target in l:targets
    call cmake#ctags#wipe(l:target)
  endfor
  call cmake#util#echo_msg('Cleared all of the generated tags for this project.')
endfunc

function! cmake#commands#generate_ctags()
  let l:targets = cmake#targets#list()
  for target in l:targets
    call cmake#ctags#generate_for_target(l:target)
  endfor
  call cmake#util#echo_msg('Generated tags for all targets.')
endfunc

function! cmake#commands#generate_local_ctags()
  if exists('b:cmake_target')
    call cmake#ctags#generate_for_target(b:cmake_target)
    call cmake#util#echo_msg('Generated tags for ' . b:cmake_target . '.')
  else
    call cmake#commands#generate_ctags()
  endif
endfunc

function! cmake#commands#clean()
  call cmake#util#echo_msg('Cleaning build...')
  call cmake#commands#invoke_target('clean')
  call cmake#util#echo_msg('Cleaned build.')
endfunc

function! cmake#commands#test()
  call cmake#util#echo_msg('Testing build...')
  call cmake#commands#invoke_target('test')
  call cmake#util#echo_msg('Tested build.')
endfunc

function! cmake#commands#rebuild_cache()
  call cmake#util#echo_msg('Rebuilding variable cmake for CMake...')
  call cmake#commands#invoke_target('rebuild_cache')
  call cmake#util#echo_msg('Rebuilt variable cmake for CMake...')
endfunc

function! cmake#commands#install()
  call cmake#util#echo_msg('Installing project...')
  call cmake#commands#invoke_target('install')
  call cmake#util#echo_msg('Installed project.')
endfunc

" TODO: Check if there was a failure of sorts on configuring.
function! cmake#commands#create_build(directory)
  if count(g:cmake_build_directories, a:directory) == 0
    call cmake#util#echo_msg("You should add '" . a:directory . "' to 'g:cmake_build_directories so CMake will be able to find it in the future.")
  endif

  " Make the directory.
  if filereadable(a:directory . "/CMakeCache.txt")
    if confirm("Remove existing project configuration?", "&Yes\&No", 'n', 'question') == 1
      call delete(a:directory . '/CMakeCache.txt')
    endif
  endif

  if !isdirectory(a:directory)
    call mkdir(a:directory, "p")
  endif

  " Pre-populate options for new CMake build.
  let l:build_options = s:get_build_opts()

  " Make the build.
  call cmake#util#echo_msg('Configuring project for the first time...')
  call cmake#util#run_cmake(l:build_options . ' -- ' .  a:directory)
  call cmake#commands#rehash_project()
  call cmake#targets#cache()
  call cmake#util#echo_msg('Project configured.')
endfunc

function! cmake#commands#rehash_project()
  call cmake#util#echo_msg('Flusing the current cache of the project...')
  let g:cmake_cache = { 'targets': '', 'files': '' }
  call cmake#util#echo_msg('Recaching entire project...')
  call cmake#targets#cache()
  call cmake#util#echo_msg('Cached the project.')
endfunction

function! cmake#commands#apply()
  command! -nargs=0 CMakeCtagsBuildAll
        \ :call cmake#commands#generate_ctags()

  command! -nargs=0 CMakeRebuildCache
        \ :call cmake#commands#rebuild_cache()

  command! -nargs=0 CMakeClean
        \ :call cmake#commands#clean()

  command! -nargs=0 CMakeCleanBuild
        \ :call s:clean_then_build()

  command! -nargs=0 CMakeTest
        \ :call cmake#commands#test()

  command! -nargs=0 CMakeInstall
        \ :call cmake#commands#install()

  command! -nargs=0 CMakeBuild
        \ :call cmake#commands#build()

  command! -nargs=0 CMakeRehashProject
        \ :call cmake#commands#rehash_project()

  command! -nargs=0 CMakeClearBufferOpts
        \ :call s:cmake_clear_buffer_opts()

  command! -nargs=0 CMakeBuildCurrent
        \ :call cmake#commands#build_current()

  command! -nargs=0 CMakeCtagsBuildCurrent
        \ :call cmake#commands#generate_local_ctags()

  command! -nargs=1 -complete=dir CMakeCreateBuild
        \ :call cmake#commands#create_build("<args>")

  command! -nargs=1 -complete=customlist,s:get_targets
        \ CMakeTarget :call cmake#targets#build("<args>")

  command! -nargs=0 CMakeInfoForCurrentFile
        \ :call s:cmake_print_info()
endfunction!

function s:cmake_clear_buffer_opts()
  if exists('b:cmake_binary_dir')
    unlet b:cmake_binary_dir
  endif

  if exists('b:cmake_target')
    unlet b:cmake_target
  endif
endfunction

function! s:cmake_print_info()
  if exists('b:cmake_target')
  let l:current_file  = fnamemodify(expand('%'), ':p')
  let l:current_flags = uniq(filter(copy(b:cmake_flags),
        \ 'v:val =~ "-f" || v:val =~ "-W"'))
  echo "CMake Info for '" . fnamemodify(l:current_file,':t') . "':\n" .
        \ "Target:              "   . b:cmake_target . "\n" .
        \ "Binary Directory:    "   . fnamemodify(b:cmake_binary_dir, ':p:.') .
        \ "\nSource Directory:    " . fnamemodify(b:cmake_source_dir, ':p:.') .
        \ "\nFlags:               " . join(l:current_flags, ', ') . "\n" .
        \ "Include Directories: "   . join(uniq(copy(b:cmake_include_dirs)), ',') . "\n"
        \ "Libraries:           "   . join(uniq(copy(b:cmake_libraries)), ',')
  endif
endfunction

function! s:clean_then_build()
  call cmake#commands#clean()
  call cmake#commands#build()
endfunc

function! s:get_targets(ArgLead,L,P)
  return filter(cmake#targets#list(), 'v:val =~ "' . a:ArgLead . '"')
endfunc

function! s:get_build_opts()
  let l:command =  [ '-G "' . g:cmake_generator . '" ']
  let l:command += [ '-DCMAKE_EXPORT_COMPILE_COMMANDS=1']
  let l:command += [ '-DCMAKE_INSTALL_PREFIX:FILEPATH='  . g:cmake_install_prefix ]
  let l:command += [ '-DCMAKE_BUILD_TYPE:STRING='        . g:cmake_build_type ]
  let l:command += [ '-DCMAKE_CXX_COMPILER:FILEPATH='    . g:cmake_cxx_compiler ]
  let l:command += [ '-DCMAKE_C_COMPILER:FILEPATH='      . g:cmake_c_compiler ]
  let l:command += [ '-DBUILD_SHARED_LIBS:BOOL='         . g:cmake_build_shared_libs ]
  let l:commandstr = join(l:command, ' ')

  return l:commandstr
endfunction!
