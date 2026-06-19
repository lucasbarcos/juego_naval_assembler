del main.obj
del io.obj
del tab.obj
del mouse.obj
del main.exe
del main.map
tasm main
tasm io
tasm tab
tasm mouse
tlink main+io+tab+mouse,main
main

