; Batalla Naval - version con carga de barcos
; Tablero 10x10, filas A-J y columnas 1-10.

.8086
.model small
.stack 100h

extrn limpiarPantalla:proc
extrn imprimirCadena:proc
extrn imprimirTablero:proc
extrn imprimirEstado:proc
extrn pedirDisparo:proc
extrn verificarDisparo:proc
extrn cargarBarcos:proc
extrn mostrarMapa:proc
extrn pausa:proc

.data
	TAM equ 10
	TOTAL_CAS equ 100 ; Si queremos agregar más casillas
	TOTAL_BAR equ 19  ; Si queremos agregar más barcos, hay que sumarle a esta var el peso de los barcos agregados

	public TxtPausa
	public TxtIntent
	public TxtAciert
	public cabecera
	public tableroReal
	public tableroVis
	public intentos
	public aciertos
	public fila
	public columna
	public posicion
	public estado

	Inicio db 0dh,0ah
	       db "              BIENVENIDOS A LA BATALLA NAVAL",0dh,0ah,0dh,0ah
	       db "                         __/___",0dh,0ah
	       db "                   _____/______|___",0dh,0ah
	       db "                   \              /",0dh,0ah
	       db "        ~~~~~ ~~~~~~\____________/~~~~~~ ~~~~~",0dh,0ah
	       db "           ~~~~~       ~~~~~        ~~~~~",0dh,0ah,24h

	titulo db 0dh,0ah,"=== BATALLA NAVAL ===",0dh,0ah,24h
	reglas db "Dispara con fila A-J y columna 1-10.",0dh,0ah
	       db "X = tocado, O = agua, ~ = sin disparar.",0dh,0ah,24h
	TxtAgua db 0dh,0ah,"Agua!",0dh,0ah,24h
	TxtTocado db 0dh,0ah,"Tocado!",0dh,0ah,24h
	TxtRepet db 0dh,0ah,"Ya disparaste ahi. No perdes intento.",0dh,0ah,24h
	TxtInval db 0dh,0ah,"Coordenada invalida. Proba otra vez.",0dh,0ah,24h
	TxtPerd db 0dh,0ah,"Perdiste! Te quedaste sin intentos.",0dh,0ah,24h
	TxtUbic db 0dh,0ah,"Los barcos estaban ubicados asi:",0dh,0ah,24h
	TxtWin db 0dh,0ah
	       db "        GGGGG    AAAAA   N   N   AAAAA   SSSSS  TTTTT  EEEEE",0dh,0ah
	       db "        G        A   A   NN  N   A   A   S        T    E",0dh,0ah
	       db "        G  GG    AAAAA   N N N   AAAAA   SSSSS    T    EEEE",0dh,0ah
	       db "        G   G    A   A   N  NN   A   A       S    T    E",0dh,0ah
	       db "        GGGGG    A   A   N   N   A   A   SSSSS    T    EEEEE",0dh,0ah,24h
	TxtIntent db 0dh,0ah,"Intentos restantes: ",24h
	TxtAciert db " | Aciertos: ",24h
	TxtPausa db 0dh,0ah,"Apreta una tecla para seguir...",24h
	cabecera db 0dh,0ah,"                       1 2 3 4 5 6 7 8 9 10",0dh,0ah,24h

	; 0 = agua, 1-6 = numero de barco
	tableroReal db TOTAL_CAS dup (0)
	tableroVis db TOTAL_CAS dup ('~')

	intentos db 35  ; si queremos modificar los intentos
	aciertos db 0
	fila db 0
	columna db 0
	posicion dw 0
	estado db 0 ; Determina error, si no se decalra ningun estado, es agua, si es 1, es tocado, el resto son problemas

.code
	main proc
		mov ax, @data
		mov ds, ax

		call limpiarPantalla
		mov dx, offset Inicio
		call imprimirCadena
		call pausa

		call cargarBarcos

juego:
		call limpiarPantalla

		mov dx, offset titulo
		call imprimirCadena
		mov dx, offset reglas
		call imprimirCadena

		call imprimirTablero
		call imprimirEstado ; Intentos y hits
		call pedirDisparo

		cmp byte ptr estado, 3
		je coordenadaInvalida

		call verificarDisparo

		cmp byte ptr estado, 2
		je disparoRepetido

		dec byte ptr intentos

		cmp byte ptr estado, 1
		je disparoTocado

		mov dx, offset TxtAgua
		call imprimirCadena
		jmp revisarFin

disparoTocado:
		mov dx, offset TxtTocado
		call imprimirCadena
		jmp revisarFin

disparoRepetido:
		mov dx, offset TxtRepet
		call imprimirCadena
		call pausa
		jmp juego

coordenadaInvalida:
		mov dx, offset TxtInval
		call imprimirCadena
		call pausa
		jmp juego

revisarFin:
		cmp byte ptr aciertos, TOTAL_BAR
		je gano
		cmp byte ptr intentos, 0
		je perdio
		call pausa
		jmp juego

gano:
		call limpiarPantalla
		mov dx, offset TxtWin
		call imprimirCadena
		call imprimirTablero
		jmp fin

perdio:
		call limpiarPantalla
		mov dx, offset TxtPerd
		call imprimirCadena
		mov dx, offset TxtUbic
		call imprimirCadena
		call mostrarMapa

fin:
		mov ax, 4c00h
		int 21h
	main endp

end main
