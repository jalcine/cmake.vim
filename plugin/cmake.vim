" File:        plugin/cmake.vim
" Description: Primary plug-in entry point for cmake.vim
" Author:      Jacky Alciné <me@jalcine.me>
" License:     MIT
" Website:     https://jalcine.github.io/cmake.vim
" Version:     0.5.5

if exists('g:loaded_cmake')
  finish
endif

let g:loaded_cmake = 1

" Capture the user's predefined 'path' so we can fall back to this when we need
" to reset said path.
let g:cmake_old_path = &path

" Instantiate the cache used to represent targets and files in CMake. This
" allows for a (tiny bit) speedier look up for these bits of information at the
" cost of memory.
let g:cmake_cache = {
  \ 'targets' : {},
  \ 'files' : {}
  \ }


" Local Function: s:get_cpp_compiler()
" Obtains the path to the C++ compiler used on the system.
func! s:get_cpp_compiler()
  if exists('$CXX')
    return $CXX
  endif

  return "/usr/bin/c++"
endfunc

" Local Function: s:get_c_compiler()
" Obtains the path to the C compiler used on the system.
func! s:get_c_compiler()
  if exists('$CC')
    return $CC
  endif

  return "/usr/bin/cc"
endfunc

" Local Function: s:setauto()
" With the provided 'name', it sets a variable named 'name' to the value
" 'value' if it hasn't been defined yet.
func! s:setauto(name, value)
  let {a:name} = a:value
endfunc

let s:options = {
  \  'g:cmake_build_directories': [ 'build' ],
  \  'g:cmake_build_shared_libs': 1,
  \  'g:cmake_build_toolchain':   'gnumake',
  \  'g:cmake_build_type':        'RelWithDebInfo',
  \  'g:cmake_c_compiler':        s:get_c_compiler(),
  \  'g:cmake_cxx_compiler':      s:get_cpp_compiler(),
  \  'g:cmake_ctags':             {
  \       'executable':           'ctags'
  \  },
  \  'g:cmake_exec':              { 
  \       'async':                'vim',
  \       'sync':                 'vim'
  \  },
  \  'g:cmake_extensions':        [],
  \  'g:cmake_flags':             { 
  \       'filter':               1, 
  \       'inject':               1, 
  \       'reload':               'on-demand'
  \  },
  \  'g:cmake_generator':         'Unix Makefiles',
  \  'g:cmake_install_prefix':    '/usr/local',
  \  'g:cmake_set_makeprg':       1,
  \ }

" Public Function: cmake#set_options()
" Automatically populates options not yet defined for CMake.
func! cmake#set_options()
  for aOption in keys(s:options)
    call s:setauto(aOption, s:options[aOption])
  endfor
endfunc

call cmake#set_options()
call cmake#extension#init()
call cmake#augroup#init()
