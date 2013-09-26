func! cmake#commands#build()
  echomsg "[cmake] Building all targets..."
  let l:output = cmake#util#run_make("all")
  echo l:output
endfunc

func! cmake#commands#clean()
  echomsg "[cmake] Cleaning..."
  let l:output = cmake#util#run_make("clean")
  echo l:output
endfunc

func! cmake#commands#test()
  echomsg "[cmake] Testing project..."
  let l:output = cmake#util#run_make("test")
  echo l:output
endfunc

func! cmake#commands#install()
  echomsg "[cmake] Installing project..."
  let l:output = cmake#util#run_make("install")
  echo l:output
endfunc

" TODO: Allow choosing of build directory name?
func! cmake#commands#create_build()
endfunc
