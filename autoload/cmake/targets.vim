" File:             autoload/cmake/targets.vim
" Description:      Handles the logic of interacting with targets.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.2.0
" Last Modified:    2013-09-28 15:21:40 EDT

func! cmake#targets#build()
endfunc!

func! cmake#targets#clean()
endfunc!

func! cmake#targets#list()
endfunc!

func! cmake#targets#files()
endfunc!

func! cmake#targets#flags(target)
  let l:flags_file = glob(cmake#util#binary_dir() . '**/' . a:target . '.dir/**/*flags.make', 1)
  if len(l:flags_file) == 0 || !filereadable(l:flags_file)
    return 0
  endif

  return { 
    \ "c"   : cmake#flags#parse(system("grep 'C_FLAGS = ' " . l:flags_file . " | cut -b 11-")),
    \ "cpp" : cmake#flags#parse(system("grep 'CXX_FLAGS = ' " . l:flags_file . " | cut -b 13-"))
    \  }
endfunc!

