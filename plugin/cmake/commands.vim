func! cmake#commands#build()
  " Build the KRAKEN!
  call cmake#util#run_make("all")
endfunc

func! cmake#commands#clean()
  " Clean your room.
  call cmake#util#run_make("clean")
endfunc

func! cmake#commands#test()
  call cmake#util#run_make("test")
endfunc

func! cmake#commands#install()
  call cmake#utils#run_make("install")
endfunc
