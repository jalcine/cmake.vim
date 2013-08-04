func! cmake#util#init_cmake(dir)
	if !isdirectory(a:dir)
		echomsg "[cmake] Can't find build directory."
		return 0
	else
		let l:command =  [ "-DCMAKE_INSTALL_PREFIX:FILEPATH="  . g:cmake_install_prefix ]
		let l:command += [ "-DCMAKE_BUILD_TYPE:STRING="        . g:cmake_build_type ]
		let l:command += [ "-DCMAKE_CXX_COMPILER:FILEPATH="    . g:cmake_cxx_compiler ]
		let l:command += [ "-DCMAKE_C_COMPILER:FILEPATH="      . g:cmake_c_compiler ] 
		let l:command += [ "-DBUILD_SHARED_LIBS:BOOL="         . g:cmake_build_shared_libs ]
		let l:commandstr = join(l:command, " ")
		return cmake#util#run_cmake(l:commandstr, a:dir)
	endif
endfunc!

func! cmake#util#shell_exec(cmd)
	if g:cmake_use_vimux == 1 && g:loaded_vimux == 1
		call VimuxRunCommand(a:cmd)
		return 0
	else
		return system(a:cmd)
	endif
endfunc

func! cmake#util#run_make(argstr, dir)
	if !isdirectory(a:dir)
		echoerr "[cmake] Can't find directory to execute CMake's Makefile at '" . a:dir . "'"
		return 0
	endif
	return cmake#util#shell_exec("make -C " . a:dir . " " . a:argstr)
endfunc

func! cmake#util#run_cmake(argstr, dir)
	if !isdirectory(a:dir)
		echoerr "[cmake] Can't find directory to execute CMake at '" . a:dir . "'"
		return 0
	endif
	return cmake#util#shell_exec("cd " . a:dir . " && cmake .. " . a:argstr)
endfunc

func! cmake#util#find_source_dir(dir)
	if !isdirectory(a:dir)
		echomsg "[cmake] Not a directory '" . a:dir . "'"
		return 0
	endif

	if filereadable(a:dir . "/CMakeLists.txt")
		return a:dir
	else
		if !isdirectory(a:dir) || a:dir == "/" || a:dir == "/home" || a:dir == "/Users"
			return 0
		else
			let the_dir = system("dirname -z " . shellescape(a:dir))
			return cmake#util#find_source_dir(the_dir)
		endif
	endif
endfunc

func! cmake#util#find_binary_dir(dir)
	let srcdir = cmake#util#find_source_dir(a:dir)
	if isdirectory(srcdir)
		return srcdir . "/build"
	else
		return 0
	endif
endfunc

func! cmake#util#has_cmake_build(dir)
	return isdirectory(cmake#util#find_binary_dir(a:dir))
endfunc
