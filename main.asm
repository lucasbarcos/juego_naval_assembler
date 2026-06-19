; ARCHIVO PRINCIPAL DE BATALLA NAVAL
;
; Este archivo conecta todas las librerias y controla el orden del juego.
; Aca estan las variables que comparten los otros archivos, los mensajes
; principales y el ciclo que se repite mientras queden intentos.
;
; COMO FUNCIONA:
; 1. Inicializa el segmento de datos para poder usar las variables.
; 2. Muestra la portada grafica y reproduce el sonido de inicio.
; 3. Llama a cargarBarcos para que se coloquen los 6 barcos.
; 4. En cada turno imprime el tablero y espera un disparo con el mouse.
; 5. Segun estado informa agua, tocado, repetido o coordenada invalida.
; 6. Termina mostrando GANASTE o PERDISTE.
;
; RELACION CON LOS OTROS ARCHIVOS:
; io.asm    = impresion, teclado, colores, pausas y limpieza de pantalla.
; tab.asm   = tablero, carga de barcos, disparos y reglas del juego.
; mouse.asm = seleccion de las casillas usando el mouse.
; son.asm   = musica y efectos hechos con el parlante interno.
; graf.asm  = portada grafica en modo VGA.
;
; VARIABLES IMPORTANTES:
; tableroReal guarda donde estan los barcos.
; tableroVis guarda lo que puede ver el jugador.
; estado comunica el resultado de las rutinas: 0 agua, 1 tocado,
; 2 disparo repetido y 3 entrada invalida.
; TOTAL_BAR es la cantidad total de casillas ocupadas por barcos.

.8086
.model small
.stack 100h

extrn limpiarPantalla:proc
extrn mostrarGraf:proc
extrn cerrarGraf:proc
extrn imprimirCadena:proc
extrn imprimirCadenaColor:proc
extrn imprimirTablero:proc
extrn imprimirEstado:proc
extrn pedirDisparo:proc
extrn pedirDisparoMouse:proc
extrn verificarDisparo:proc
extrn cargarBarcos:proc
extrn mostrarMapa:proc
extrn pausa:proc
extrn sonidoAgua:proc
extrn sonidoTocado:proc
extrn sonidoVictoria:proc
extrn sonidoInicio:proc
extrn sonidoCarga:proc
extrn sonidoDerrota:proc

.data
	TAM equ 10; Si queremos agregar mas casillas
	TOTAL_CAS equ 100 ; Si queremos agregar mas casillas
	TOTAL_BAR equ 19 ; 19 casillas total son 6 barcos (1 de 4 casillas, 2 de 3 casillas, 3 de 2 casillas y 4 de 1 casilla)
	                ; Si queremos agregar mas barcos, hay que aumentar esta constante al número total de casillas ocupadas por barcos

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

	titulo db 0dh,0ah,"=== BATALLA NAVAL ===",0dh,0ah,24h
	reglas db "Hace clic en una casilla para disparar.",0dh,0ah
	       db "X = tocado, O = agua, ~ = sin disparar.",0dh,0ah,24h
	TxtAgua db 0dh,0ah,"Agua!",0dh,0ah,24h
	TxtTocado db 0dh,0ah,"Tocado!",0dh,0ah,24h
	TxtRepet db 0dh,0ah,"Ya disparaste ahi. No perdes intento.",0dh,0ah,24h
	TxtInval db 0dh,0ah,"Coordenada invalida. Proba otra vez.",0dh,0ah,24h
	TxtPerd db 0dh,0ah,"Perdiste! Te quedaste sin intentos.",0dh,0ah,24h

	TxtLose db 0dh,0ah
	        db "        PPPPP   EEEEE   RRRRR   DDDD    IIIII   SSSSS  TTTTT  EEEEE",0dh,0ah
	        db "        P   P   E       R   R   D   D     I     S        T    E",0dh,0ah
	        db "        PPPPP   EEEE    RRRRR   D   D     I     SSSSS    T    EEEE",0dh,0ah
	        db "        P       E       R R     D   D     I         S    T    E",0dh,0ah
	        db "        P       EEEEE   R  RR   DDDD    IIIII   SSSSS    T    EEEEE",0dh,0ah,24h

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

		; portada grafica en modo VGA
		call mostrarGraf
		; la musica suena completa mientras se ve el barco
		call sonidoInicio
		; espera una tecla y vuelve al modo texto
		call cerrarGraf

		call sonidoCarga
		call cargarBarcos

juego:
		call limpiarPantalla

		mov dx, offset titulo
		call imprimirCadena
		mov dx, offset reglas
		call imprimirCadena

		call imprimirTablero
		call imprimirEstado ; Intentos y hits
		; el disparo se elige haciendo clic en el tablero
		call pedirDisparoMouse
		cmp byte ptr estado, 3
		je coordenadaInvalida

		call verificarDisparo

		cmp byte ptr estado, 2
		je disparoRepetido
		; si fue tocado no se pierde intento
		cmp byte ptr estado, 1
		je disparoTocado

		; solamente se descuenta cuando cae en agua
		dec byte ptr intentos
		call sonidoAgua
		mov dx, offset TxtAgua
		call imprimirCadena
		jmp revisarFin

disparoTocado:
		call sonidoTocado
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
		call sonidoVictoria
		call limpiarPantalla
		mov dx, offset TxtWin
		mov bl, 0Eh
		call imprimirCadenaColor
		call imprimirTablero
		jmp fin

perdio:
		call sonidoDerrota
		call limpiarPantalla
		mov dx, offset TxtLose
		mov bl, 0Ch
		call imprimirCadenaColor
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












