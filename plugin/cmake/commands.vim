func! cmake#commands#build()
  " Build the KRAKEN!
  cmake#util#run_make("all")
endfunc

func! cmake#commands#clean()
  " Clean your room.
  cmake#util#run_make("clean")
endfunc

func! cmake#commands#test()
  cmake#util#run_make("test")
endfunc

func! cmake#commands#install()
  cmake#utils#run_make("install")
endfunc
