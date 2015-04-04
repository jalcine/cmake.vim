" File:             autoload/cmake/extension/syntastic.vim
" Description:      Syntastic plugin for CMake.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.5

" TODO: Complete support of syntastic.
func! cmake#extension#syntastic#inject(args)
  let l:target = a:args.target
  let l:include_dirs = cmake#targets#include_dirs(target)
  let l:flags = cmake#targets#flags(target)

  if !exists('b:syntastic_cpp_includes')
    let b:syntastic_cpp_includes = join(l:include_dirs, ';')
  endif

  if !exists('b:syntastic_cpp_compiler_options')
    let b:syntastic_cpp_compiler_options = join(l:flags, ' ')
  endif

  if !exists('b:syntastic_cpp_clang_tidy_args')
    let b:syntastic_cpp_clang_tidy_args = '-p ' . cmake#util#binary_dir() .
          \ b:syntastic_cpp_compiler_options
  endif

  if !exists('b:syntastic_cpp_clang_check_args')
    let b:syntastic_cpp_clang_check_args = '-p ' . cmake#util#binary_dir() .
          \ b:syntastic_cpp_compiler_options
  endif
endfunc
