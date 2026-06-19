; LIBRERIA DEL TABLERO Y DE LAS REGLAS
;
; Este archivo se encarga de casi toda la logica de la batalla naval:
; dibuja los tableros, coloca los barcos, valida que entren, registra
; disparos y controla cuando un barco queda hundido.
;
; COMO FUNCIONA:
; 1. cargarBarcos recorre la lista 5, 4, 3, 3, 2, 2.
; 2. El mouse elige la casilla inicial y el teclado pide H o V.
; 3. validarBarco revisa limites y evita superponer barcos.
; 4. ponerBarco guarda en cada casilla el numero del barco.
; 5. verificarDisparo compara el tablero visible con el tablero real.
; 6. golpes cuenta los aciertos recibidos por cada barco.
; 7. hundidos permite mostrar a la derecha los barcos ya destruidos.
;
; DATOS IMPORTANTES:
; barcos   = largo de cada uno de los 6 barcos.
; golpes   = cantidad de impactos que recibio cada barco.
; hundidos = vale 1 cuando ese barco ya fue destruido.
; posicion = indice entre 0 y 99 calculado como fila * 10 + columna.
;
; Si se cambia la cantidad o el largo de los barcos tambien hay que
; revisar CANTBAR, barcos, golpes, hundidos y TOTAL_BAR de main.asm.

.8086
.model small

TAM equ 10 ;Si cambiar TAM, sumarle uno y asignarselo a VALIDATE_TAM_SIZE
VALIDATE_TAM_SIZE equ 11
CANTBAR equ 6  ; Si queremos agregar más barcos, acá hay que aumentar esta constante al número de barcos


extrn limpiarPantalla:proc
extrn imprimirCadena:proc
extrn imprimirChar:proc
extrn imprimirCharColor:proc
extrn leerTecla:proc
extrn leerHastaEnter:proc
extrn saltoLinea:proc
extrn imprimirNumero:proc
extrn pausa:proc
extrn pedirCasillaMouse:proc

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

	barcos db 5,4,3,3,2,2 ; Si queremos agregar m?s barcos, ac? ser?a
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
	mov largoAct, al ; Determinamos con que barco laburamos

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
	add al, 'A' ; Podemos hacer esto porque sabemos que el tablero siempre va a lucir igual, si es realmente la referencia a la fila
	mov dl, al
	push bx
	mov bl, 0Eh
	call imprimirCharColor
	pop bx
	mov dl, ' '
	call imprimirChar
	mov dl, ' ' ; estos espacios son para tirar facha nomas, para que quede lindo
	call imprimirChar

	mov cx, TAM ; El tama?o de la grilla, si pedro pide hacerlo m?s grande o chico, cambia TAM

colTab:
	push bx
	mov dl, tableroVis[bx]
	mov bl, 0Bh            ; celeste para casilla sin disparar
	cmp dl, 'O'
	jne compXColor
	mov bl, 09h             ; azul para agua
compXColor:
	cmp dl, 'X'
	jne impCasColor
	mov bl, 0Ch             ; rojo para acierto
impCasColor:
	call imprimirCharColor
	pop bx
	mov dl, ' '
	call imprimirChar
	inc bx
	loop colTab

	call saltoLinea ; Terminamos de imprimir una fila y nos tenemos que pasar a la siguiente, como puse antes, si ser? el iterador real
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

mostrarMapa proc ; Primera carga del tablero, cuando cargamos los barcos
	push ax
	push bx
	push cx
	push dx
	push si

	mov dx, offset cabecera ; solo es el header del tablero
	call imprimirCadena

	mov bx, 0 ; iterador de columna
	mov si, 0 ; iterador de fila

filaReal:
	mov dx, offset Sangria
	call imprimirCadena
	mov ax, si
	add al, 'A'
	mov dl, al
	push bx
	mov bl, 0Eh
	call imprimirCharColor
	pop bx
	mov dl, ' '
	call imprimirChar
	mov dl, ' '
	call imprimirChar

	mov cx, TAM

colReal:
	push bx
	cmp byte ptr tableroReal[bx], 0 ; Necesitamos un tablero real y uno visible para que el enemigo no vea lo mismo que guardamos en el tablero original, si no, ver?a los barcos jaja. En la primera carga, el estratega ve sus barcos a?adidos con #
	je impAgua
	mov dl, '#'
	mov bl, 0Ah            ; verde para barcos
	jmp impReal
impAgua:
	mov dl, '~'
	mov bl, 0Bh            ; celeste para agua
impReal:
	call imprimirCharColor
	pop bx
	mov dl, ' '
	call imprimirChar
	inc bx
	loop colReal

	call saltoLinea ; Si terminamos la fila, nos vamos a la siguiente
	inc si
	cmp si, TAM ; Si terminamos, terminamos pue
	jb filaReal

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
mostrarMapa endp

pedirInicioBarco proc
	; primero se elige con el mouse la casilla inicial
	call pedirCasillaMouse
	cmp byte ptr estado, 3
	je finPedirIni

	; despues del clic se pide H o V por teclado
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
	sub al, 'A' ; esto es importante para obtener el resultado numerico de la fila
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
	je posibleDiez ; Lamentablemente toca hacer unas validaciones medio chanchas por los metodos de ingreso de datos que tenemos
	cmp al, '2'
	jb colMal ; Toca comparar con 2 porque si comparamos con 1, perdemos la posibilidad de ingresar el 10
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
	; no sacar esta validacion: fila inicial + largo no puede superar TAM
	; si se permite TAM+1 el barco se escribe fuera de la cuadricula
	cmp al, TAM
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
	; no sacar esta validacion: columna inicial + largo no puede superar TAM
	; evita que un barco horizontal continue en la fila siguiente
	cmp al, TAM ; esto es lo qu evalida horizontalmente, si es mayor que el tama?o de la grilla, no puede entrar, tener cuidado con la validaci?n en caso de cambiar el tama?o de la grilla
	ja barcoNo
	mov bx, posicion
	mov cl, largoAct
	mov ch, 0
valH: ;tanto valH como valV lo que hacen es validar si chocamos con otro barquito
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

	mov dh, 8
	mov dl, 52
	call ponerCursor
	mov dx, offset TxtPanel
	call imprimirCadena

	mov byte ptr rowSide, 10
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
	push bx
	mov dl, 'X'
	mov bl, 0Ch
	call imprimirCharColor
	pop bx
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

hayBarco: ; como funciona esto? cada barco hace referencia a un indice en "array" barcos, en golpes guardamos la cantidad de golpes que recibi? cada barco en base a su indice. si barcos[indice] == golpes[indice], entonces el barco est? destruido, es sencillo.
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










