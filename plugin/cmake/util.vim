func! cmake#util#init_cmake()
	let l:dir = cmake#util#rootdir()
	if !isdirectory(l:dir)
		echomsg "[cmake] Can't find build directory."
		return 0
	else
		let l:command =  [ "-DCMAKE_INSTALL_PREFIX:FILEPATH="  . g:cmake_install_prefix ]
		let l:command += [ "-DCMAKE_BUILD_TYPE:STRING="        . g:cmake_build_type ]
		let l:command += [ "-DCMAKE_CXX_COMPILER:FILEPATH="    . g:cmake_cxx_compiler ]
		let l:command += [ "-DCMAKE_C_COMPILER:FILEPATH="      . g:cmake_c_compiler ] 
		let l:command += [ "-DBUILD_SHARED_LIBS:BOOL="         . g:cmake_build_shared_libs ]
		let l:commandstr = join(l:command, " ")
		return cmake#util#run_cmake(l:commandstr)
	endif
endfunc!

func! cmake#util#run_make(argstr)
	let l:dir = cmake#util#rootdir()
	if !isdirectory(l:dir)
		echoerr "[cmake] Can't find build directory."
		return 0
	else
		let l:output = system("make -C " . cmake#util#rootdir() . " " . a:argstr)
		return l:output
	endif
endfunc

func! cmake#util#find_source_dir(dir)
	if !isdirectory(a:dir)
		echomsg "[cmake] Not a directory '" . a:dir . "'"
		return 0
	endif

	if filereadable(a:dir . "/CMakeLists.txt") && isdirectory(a:dir . "/build")
		echo "[cmake] Found top-level source directory at " . a:dir
		return a:dir
	else
		if !isdirectory(a:dir)
			return 0
		else
			let the_dir = system("dirname -z " . shellescape(a:dir))
			echo "[cmake] Trying " . the_dir
			return cmake#util#find_source_dir(the_dir)
		endif
	endif
endfunc

func! cmake#util#find_binary_dir(dir)
	let srcdir = cmake#util#find_source_dir(a:dir)
	let bindir = srcdir . "/build"
	if isdirectory(bindir)
		return bindir
	endif
endfunc
