; Libreria propia con rutinas del tablero y reglas.

.8086
.model small

TAM equ 10
CANTBAR equ 6

extrn limpiarPantalla:proc
extrn imprimirCadena:proc
extrn imprimirChar:proc
extrn leerTecla:proc
extrn leerHastaEnter:proc
extrn saltoLinea:proc
extrn imprimirNumero:proc
extrn pausa:proc

extrn TxtIntent:byte
extrn TxtAciert:byte
extrn cabecera:byte
extrn tableroReal:byte
extrn tableroVis:byte
extrn intentos:byte
extrn aciertos:byte
extrn fila:byte
extrn columna:byte
extrn posicion:word
extrn estado:byte

.data
	Carga db 0dh,0ah,"=== CARGA DE BARCOS ===",0dh,0ah,24h
	Lista db "Barcos: 5, 4, 3, 3, 2, 2 casillas.",0dh,0ah,24h
	Barco db 0dh,0ah,"Cargando barco de ",24h
	Cas db " casillas",0dh,0ah,24h
	TxtFila db "Fila inicial (A-J): ",24h
	Col db "Columna inicial (1-10): ",24h
	Ori db "Orientacion H/V: ",24h
	Mal db 0dh,0ah,"No se puede poner ahi. Prueba otra vez.",0dh,0ah,24h
	OK db 0dh,0ah,"Barco cargado.",0dh,0ah,24h
	TxtFin db 0dh,0ah,"Barcos cargados. Ahora empieza el juego.",0dh,0ah,24h
	Sangria db "                    ",24h
	TxtHund db 0dh,0ah,"Se hundio un barco de ",24h
	TxtPanel db "Barcos hundidos:",24h
	TxtBarH db "Hundido el barco ",24h
	rowSide db 0

	barcos db 5,4,3,3,2,2
	golpes db 6 dup (0)
	hundidos db 6 dup (0)
	barcoAct db 0
	largoAct db 0
	orient db 0

.code
public imprimirEstado
public imprimirTablero
public pedirDisparo
public cargarBarcos
public verificarDisparo
public mostrarMapa

cargarBarcos proc
	push ax
	push bx
	push cx
	push dx

	mov barcoAct, 0

sigBarco:
	call limpiarPantalla
	mov dx, offset Carga
	call imprimirCadena
	mov dx, offset Lista
	call imprimirCadena
	call mostrarMapa

	mov bl, barcoAct
	mov bh, 0
	mov al, barcos[bx]
	mov largoAct, al

	mov dx, offset Barco
	call imprimirCadena
	mov al, largoAct
	call imprimirNumero
	mov dx, offset Cas
	call imprimirCadena

	call pedirInicioBarco
	cmp byte ptr estado, 3
	je barcoMal

	call validarBarco
	cmp byte ptr estado, 3
	je barcoMal

	call ponerBarco
	mov dx, offset OK
	call imprimirCadena
	call pausa

	inc barcoAct
	cmp byte ptr barcoAct, CANTBAR
	jb sigBarco

	call limpiarPantalla
	call mostrarMapa
	mov dx, offset TxtFin
	call imprimirCadena
	call pausa
	jmp finCarga

barcoMal:
	mov dx, offset Mal
	call imprimirCadena
	call pausa
	jmp sigBarco

finCarga:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
cargarBarcos endp

imprimirEstado proc
	push ax
	push dx

	mov dx, offset TxtIntent
	call imprimirCadena
	mov al, intentos
	call imprimirNumero

	mov dx, offset TxtAciert
	call imprimirCadena
	mov al, aciertos
	call imprimirNumero

	call saltoLinea

	pop dx
	pop ax
	ret
imprimirEstado endp

imprimirTablero proc
	push ax
	push bx
	push cx
	push dx
	push si

	mov dx, offset cabecera
	call imprimirCadena

	mov bx, 0
	mov si, 0

filaTab:
	mov dx, offset Sangria
	call imprimirCadena
	mov ax, si
	add al, 'A'
	mov dl, al
	call imprimirChar
	mov dl, ' '
	call imprimirChar
	mov dl, ' '
	call imprimirChar

	mov cx, TAM

colTab:
	mov dl, tableroVis[bx]
	call imprimirChar
	mov dl, ' '
	call imprimirChar
	inc bx
	loop colTab

	call saltoLinea
	inc si
	cmp si, TAM
	jb filaTab

	call imprimirHundidos
	call ponerCursorBajo

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
imprimirTablero endp

mostrarMapa proc
	push ax
	push bx
	push cx
	push dx
	push si

	mov dx, offset cabecera
	call imprimirCadena

	mov bx, 0
	mov si, 0

filaReal:
	mov dx, offset Sangria
	call imprimirCadena
	mov ax, si
	add al, 'A'
	mov dl, al
	call imprimirChar
	mov dl, ' '
	call imprimirChar
	mov dl, ' '
	call imprimirChar

	mov cx, TAM

colReal:
	cmp byte ptr tableroReal[bx], 0
	je impAgua
	mov dl, '#'
	jmp impReal
impAgua:
	mov dl, '~'
impReal:
	call imprimirChar
	mov dl, ' '
	call imprimirChar
	inc bx
	loop colReal

	call saltoLinea
	inc si
	cmp si, TAM
	jb filaReal

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
mostrarMapa endp

pedirInicioBarco proc
	call pedirFila
	cmp byte ptr estado, 3
	je finPedirIni
	call pedirCol
	cmp byte ptr estado, 3
	je finPedirIni
	call pedirOri
finPedirIni:
	ret
pedirInicioBarco endp

pedirDisparo proc
	call pedirFila
	cmp byte ptr estado, 3
	je finPedirDisp
	call pedirCol
	cmp byte ptr estado, 3
	je finPedirDisp
	call calcularPosicion
finPedirDisp:
	ret
pedirDisparo endp

pedirFila proc
	push ax
	push dx

	mov estado, 0
	mov dx, offset TxtFila
	call imprimirCadena
	call leerTecla
	call leerHastaEnter

	cmp al, 'a'
	jb valFila
	cmp al, 'z'
	ja valFila
	sub al, 20h

valFila:
	cmp al, 'A'
	jb filaMal
	cmp al, 'J'
	ja filaMal
	sub al, 'A'
	mov fila, al
	jmp finFila

filaMal:
	mov estado, 3

finFila:
	pop dx
	pop ax
	ret
pedirFila endp

pedirCol proc
	push ax
	push dx

	mov dx, offset Col
	call imprimirCadena
	call leerTecla

	cmp al, '1'
	je posibleDiez
	cmp al, '2'
	jb colMal
	cmp al, '9'
	ja colMal
	sub al, '1'
	mov columna, al
	call leerHastaEnter
	jmp finCol

posibleDiez:
	call leerTecla
	cmp al, '0'
	je esDiez
	cmp al, 0dh
	je esUno
	call leerHastaEnter
	jmp colMal

esDiez:
	mov columna, 9
	call leerHastaEnter
	jmp finCol

esUno:
	mov columna, 0
	jmp finCol

colMal:
	mov estado, 3

finCol:
	pop dx
	pop ax
	ret
pedirCol endp

pedirOri proc
	push ax
	push dx

	mov dx, offset Ori
	call imprimirCadena
	call leerTecla
	call leerHastaEnter

	cmp al, 'h'
	jne compVmin
	mov al, 'H'
compVmin:
	cmp al, 'v'
	jne valOri
	mov al, 'V'

valOri:
	cmp al, 'H'
	je oriOk
	cmp al, 'V'
	je oriOk
	mov estado, 3
	jmp finOri

oriOk:
	mov orient, al

finOri:
	pop dx
	pop ax
	ret
pedirOri endp

calcularPosicion proc
	push ax
	push bx

	mov al, fila
	mov bl, TAM
	mul bl
	add al, columna
	mov ah, 0
	mov posicion, ax

	pop bx
	pop ax
	ret
calcularPosicion endp

validarBarco proc
	push ax
	push bx
	push cx
	push dx

	call calcularPosicion

	mov al, orient
	cmp al, 'H'
	je valHorizontal

	mov al, fila
	add al, largoAct
	cmp al, 11
	ja barcoNo
	mov bx, posicion
	mov cl, largoAct
	mov ch, 0
valV:
	cmp byte ptr tableroReal[bx], 0
	jne barcoNo
	add bx, TAM
	loop valV
	jmp barcoSi

valHorizontal:
	mov al, columna
	add al, largoAct
	cmp al, 11
	ja barcoNo
	mov bx, posicion
	mov cl, largoAct
	mov ch, 0
valH:
	cmp byte ptr tableroReal[bx], 0
	jne barcoNo
	inc bx
	loop valH
	jmp barcoSi

barcoNo:
	mov estado, 3
	jmp finValBarco

barcoSi:
	mov estado, 0

finValBarco:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
validarBarco endp

ponerBarco proc
	push ax
	push bx
	push cx

	mov bx, posicion
	mov cl, largoAct
	mov ch, 0
	mov al, barcoAct
	inc al

	cmp orient, 'H'
	je ponerH

ponerV:
	mov tableroReal[bx], al
	add bx, TAM
	loop ponerV
	jmp finPoner

ponerH:
	mov tableroReal[bx], al
	inc bx
	loop ponerH

finPoner:
	pop cx
	pop bx
	pop ax
	ret
ponerBarco endp

ponerCursor proc
	mov ah, 02h
	mov bh, 0
	int 10h
	ret
ponerCursor endp

ponerCursorBajo proc
	push dx
	mov dh, 18
	mov dl, 0
	call ponerCursor
	pop dx
	ret
ponerCursorBajo endp

imprimirHundidos proc
	push ax
	push bx
	push cx
	push dx
	push si

	mov dh, 5
	mov dl, 52
	call ponerCursor
	mov dx, offset TxtPanel
	call imprimirCadena

	mov byte ptr rowSide, 7
	mov si, 0

recHund:
	cmp si, CANTBAR
	jae finHund
	cmp byte ptr hundidos[si], 1
	jne sigHund

	mov dh, rowSide
	mov dl, 52
	call ponerCursor
	mov dx, offset TxtBarH
	call imprimirCadena

	mov cl, barcos[si]
	mov ch, 0
impXs:
	mov dl, 'X'
	call imprimirChar
	loop impXs

	inc byte ptr rowSide

sigHund:
	inc si
	jmp recHund

finHund:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
imprimirHundidos endp

verificarDisparo proc
	push ax
	push bx
	push dx
	push si

	mov bx, posicion

	cmp byte ptr tableroVis[bx], '~'
	jne yaDisparo

	cmp byte ptr tableroReal[bx], 0
	jne hayBarco

	mov tableroVis[bx], 'O'
	mov estado, 0
	jmp finVerificar

hayBarco:
	mov al, tableroReal[bx]
	mov tableroVis[bx], 'X'
	inc aciertos
	mov ah, 0
	mov si, ax
	dec si
	inc golpes[si]
	mov al, golpes[si]
	cmp al, barcos[si]
	jne noHundido
	mov byte ptr hundidos[si], 1
	mov dx, offset TxtHund
	call imprimirCadena
	mov al, barcos[si]
	call imprimirNumero
	mov dx, offset Cas
	call imprimirCadena
noHundido:
	mov estado, 1
	jmp finVerificar

yaDisparo:
	mov estado, 2

finVerificar:
	pop si
	pop dx
	pop bx
	pop ax
	ret
verificarDisparo endp

end


