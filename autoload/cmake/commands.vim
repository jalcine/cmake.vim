func! cmake#commands#build()
	echomsg "[cmake] Building all targets..."
	let l:output = cmake#util#run_make("all",getcwd())
	echo l:output
endfunc

func! cmake#commands#clean()
	echomsg "[cmake] Cleaning..."
	let l:output = cmake#util#run_make("clean",getcwd())
	echo l:output
endfunc

func! cmake#commands#test()
	echomsg "[cmake] Testing project..."
	let l:output = cmake#util#run_make("test",getcwd())
	echo l:output
endfunc

func! cmake#commands#install()
	echomsg "[cmake] Installing project..."
	let l:output = cmake#util#run_make("install",getcwd())
	echo l:output
endfunc

" TODO: Allow choosing of build directory name?
func! cmake#commands#create_build()
	let srcdir = cmake#util#find_source_dir(getcwd())
	if !isdirectory(srcdir)
		echom "[cmake] Can't find sources for CMake."
	endif

	let bindir = cmake#util#find_binary_dir(srcdir)
	if !isdirectory(bindir)
		echo "[cmake] Making build directory '" . bindir . "'..."
		echo system("mkdir -p " . bindir)
	endif

	echomsg "[cmake] Configuring project..."
	echo cmake#util#init_cmake(bindir)
	echomsg "[cmake] Created build."
endfunc

func! cmake#commands#delete_build()
	let bindir = cmake#util#find_binary_dir(getcwd())

	if !isdirectory(bindir)
		echom "[cmake] No CMake build system found."
		return 0
	else
		echom "[cmake] Deleting files under " . bindir . "...")
		cmake#util#shell_exec("rm -rv" . bindir)
	endif
endfunc
