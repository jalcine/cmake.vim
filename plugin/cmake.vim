if exists("g:cmake_plugin_loaded") 
	finish
end

let g:cmake_plugin_loaded = 1

func! s:setauto(name, value)
	if !exists(a:name)
		let {a:name} = a:value
	endif
endfunc

" Set configuration options.
call s:setauto("g:cmake_cxx_compiler", "clang++")
call s:setauto("g:cmake_c_compiler", "clang")
call s:setauto("g:cmake_build_dirs", [ "build" ])
call s:setauto("g:cmake_build_type", "Debug" )
call s:setauto("g:cmake_install_prefix", "$HOME/.local")
call s:setauto("g:cmake_build_shared_libs", 1)
call s:setauto("g:cmake_set_makeprg", 1)
call s:setauto("g:cmake_use_vimux", 0)

" Set Ex commands.
command! -buffer -nargs=0 CMakeBuild       :call cmake#commands#build()
command! -buffer -nargs=0 CMakeInstall     :call cmake#commands#install()
command! -buffer -nargs=0 CMakeClean       :call cmake#commands#clean()
command! -buffer -nargs=0 CMakeTest        :call cmake#commands#test()
command! -buffer -nargs=0 CMakeCreateBuild :call cmake#commands#create_build()
command! -buffer -nargs=0 CMakeDeleteBuild :call cmake#commands#delete_build()
