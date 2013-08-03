if exists("g:cmake_plugin_loaded") 
	finish
end

let g:cmake_plugin_loaded = 1

func s:auto_set(name, value)
	s:autoset(a:name)
	let {a:name} = a:value
endfunc

" Set configuration options.
s:auto_set("g:cmake_cxx_compiler", "clang++")       
s:auto_set("g:cmake_c_compiler", "clang")
s:auto_set("g:cmake_build_dirs", [ "build" ])
s:auto_set("g:cmake_build_type", "Debug" )
s:auto_set("g:cmake_install_prefix", "$HOME/.local")
s:auto_set("g:cmake_build_shared_libs", 1)
s:auto_set("g:cmake_set_makeprg", 1)

" Set Ex commands.
command! -buffer -nargs=0 CMakeBuild       :call cmake#commands#build()
command! -buffer -nargs=0 CMakeInstall     :call cmake#commands#install()
command! -buffer -nargs=0 CMakeClean       :call cmake#commands#clean()
command! -buffer -nargs=0 CMakeTest        :call cmake#commands#test()
command! -buffer -nargs=0 CMakeCreateBuild :call cmake#commands#create_build()
command! -buffer -nargs=0 CMakeDeleteBuild :call cmake#commands#delete_build()

" Change the `:make` command.
" TODO: Should this happen only in `CMakeLists.txt` files?
if g:cmake_set_makeprg == 1
	let s:dir = cmake#util#rootdir()
	if s:dir != 0
		let &mp="make -C " . s:dir
	endif
endif
