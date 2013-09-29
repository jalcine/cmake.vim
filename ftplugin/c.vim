" File:             ftplugin/c.vim
" Description:      C entry point for cmake.vim.
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.2.2
" Last Modified:    2013-09-28 15:19:06 EDT

" The power of refactoring led to this.
if !empty(cmake#util#binary_dir())
  call cmake#util#handle_injection()
endif
