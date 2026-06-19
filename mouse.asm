; Libreria para elegir una casilla del tablero usando el mouse.
; Si DOSBox no encuentra mouse, vuelve al ingreso por teclado.

.8086
.model small

extrn imprimirCadena:proc
extrn pedirDisparo:proc
extrn fila:byte
extrn columna:byte
extrn posicion:word
extrn estado:byte

.data
	TxtMouse db 0dh,0ah,"Hace clic sobre una casilla del tablero.",0dh,0ah,24h
	TxtSinM db 0dh,0ah,"No se encontro mouse. Usa fila y columna.",0dh,0ah,24h
	FilaBase db 0

.code
public pedirDisparoMouse
public pedirCasillaMouse

; durante el juego la fila A esta en la linea 6
pedirDisparoMouse proc
	mov byte ptr FilaBase, 6
	call leerCasillaMouse
	ret
pedirDisparoMouse endp

; durante la carga la fila A esta en la linea 5
pedirCasillaMouse proc
	mov byte ptr FilaBase, 5
	call leerCasillaMouse
	ret
pedirCasillaMouse endp

; rutina comun que espera el clic y calcula fila y columna
leerCasillaMouse proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	mov estado, 0

	; funcion 0 de int 33h: inicia y revisa si hay mouse
	mov ax, 0
	int 33h
	cmp ax, 0
	jne tieneMouse
	jmp sinMouse

tieneMouse:

	mov dx, offset TxtMouse
	call imprimirCadena

	; el puntero queda libre por toda la pantalla
	; si se hace clic afuera, la coordenada queda invalida

	; muestro el puntero
	mov ax, 1
	int 33h

	; espero que el boton este libre para no tomar un clic anterior
esperarLibre:
	mov ax, 3
	int 33h
	test bx, 1
	jnz esperarLibre

esperarClic:
	; funcion 3: BX botones, CX posicion X, DX posicion Y
	mov ax, 3
	int 33h
	test bx, 1
	jz esperarClic

	; guardo X e Y antes de esperar que se suelte el boton
	mov di, cx
	mov si, dx

esperarSuelta:
	mov ax, 3
	int 33h
	test bx, 1
	jnz esperarSuelta

	; oculto el puntero para que no moleste al redibujar
	mov ax, 2
	int 33h

	; paso X de pixels a columna de texto: X / 8
	mov ax, di
	xor dx, dx
	mov bx, 8
	div bx

	; las casillas ocupan desde la columna 23 hasta la 42
	cmp ax, 23
	jb clicInvalido
	cmp ax, 42
	ja clicInvalido
	sub ax, 23

	; cada casilla ocupa 2 columnas de texto
	xor dx, dx
	mov bx, 2
	div bx
	cmp ax, 9
	ja clicInvalido
	mov columna, al

	; paso Y de pixels a fila de texto: Y / 8
	mov ax, si
	xor dx, dx
	mov bx, 8
	div bx

	; FilaBase vale 5 durante la carga y 6 durante el juego
	xor dx, dx
	mov dl, FilaBase
	cmp ax, dx
	jb clicInvalido
	mov bx, dx
	add bx, 9
	cmp ax, bx
	ja clicInvalido
	sub ax, dx
	mov fila, al

	; posicion = fila * 10 + columna
	mov al, fila
	mov bl, 10
	mul bl
	add al, columna
	mov ah, 0
	mov posicion, ax
	jmp finMouse

clicInvalido:
	mov estado, 3
	jmp finMouse

sinMouse:
	mov dx, offset TxtSinM
	call imprimirCadena
	call pedirDisparo

finMouse:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
leerCasillaMouse endp

end








