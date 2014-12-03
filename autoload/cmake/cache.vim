" File:             plugin/cmake.vim
" Description:      Primary plug-in entry point for cmake.vim
" Author:           Jacky Alciné <me@jalcine.me>
" License:          MIT
" Website:          https://jalcine.github.io/cmake.vim
" Version:          0.5.x

function! cmake#cache#read_all()
  let l:vars_str = cmake#util#run_cmake('-Wnodev -N -LA', cmake#util#binary_dir(), '')
  let l:vars = split(l:vars_str, "\n", 0)
  let l:marker_index = index(l:vars, '-- Cache values', 0, 1)
  call remove(l:vars, 0, l:marker_index)
  let l:var_dict = {}

  for l:str in l:vars
    let l:components = split(l:str, '=')
    let l:property_components = split(l:components[0], ':')
    let l:property_name = l:property_components[0]
    call remove(l:components, 0, 0)
    let l:var_dict[l:property_name] = join(l:components, '=')
  endfor

  return l:var_dict
endfunc

function! cmake#cache#read(property)
  "if !cmake#util#has_project()
    "return ""
  "endif

  let l:all_vars = cmake#cache#read_all()
  if !has_key(l:all_vars, a:property)
    return ""
  endif

  return l:all_vars[a:property]
endfunc

function! cmake#cache#write(property,value)
  "if !cmake#util#has_project()
    "return 0
  "endif

  let l:args = '-Wnodev -D' . a:property . ':STRING=' . shellescape(a:value)
  let l:output = cmake#util#run_cmake(l:args, cmake#util#binary_dir(), '..')
  return stridx(l:output, 'Error') == -1
endfunc

function! cmake#cache#write_all(property_dict)
  for [property_name,property_value] in items(a:property_dict)
    call cmake#cache#write(property_name, property_value)
    unlet property_name
    unlet property_value
  endfor
endfunction
