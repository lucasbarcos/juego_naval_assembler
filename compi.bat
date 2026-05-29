del main.obj
del io.obj
del tab.obj
del main.exe
del main.map
tasm main
tasm io
tasm tab
tlink main+io+tab,main
main
