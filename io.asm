; LIBRERIA DE ENTRADA Y SALIDA
;
; Este archivo junta las rutinas comunes para mostrar informacion,
; leer el teclado, limpiar la pantalla y hacer pausas.
;
; COMO FUNCIONA:
; 1. Usa INT 21h para imprimir cadenas, caracteres y leer teclas.
; 2. Usa INT 10h para limpiar la pantalla y escribir con colores.
; 3. imprimirCadena recibe en DX una cadena terminada con el signo $.
; 4. imprimirChar recibe en DL el caracter que se quiere mostrar.
; 5. Las rutinas con color reciben el color en BL.
; 6. imprimirNumero convierte un numero de AL en caracteres visibles.
; 7. INT 81h es una interrupcion propia instalada desde main.asm.
;
; Este archivo no contiene reglas de la batalla naval. Se usa como una
; caja de herramientas desde main.asm, tab.asm y mouse.asm.

.8086
.model small

extrn TxtPausa:byte

.code
public imprimirCadena
public imprimirChar
public imprimirCharColor
public imprimirCadenaColor
public leerTecla
public leerHastaEnter
public saltoLinea
public limpiarPantalla
public imprimirNumero
public pausa

imprimirCadena proc
	mov ah, 9
	int 21h
	ret
imprimirCadena endp

imprimirChar proc
	mov ah, 2
	int 21h
	ret
imprimirChar endp
; imprime un caracter con color y avanza el cursor
; DL tiene el caracter y BL tiene el color
imprimirCharColor proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	; guardo caracter y color porque las interrupciones usan los registros
	mov al, dl
	mov ah, 0
	mov si, ax
	mov al, bl
	mov ah, 0
	mov di, ax

	; leo la posicion actual del cursor
	mov ah, 03h
	mov bh, 0
	int 10h

	; la interrupcion propia recibe AL = caracter y BL = color
	mov ax, si
	mov bx, di
	int 81h

	; avanzo el cursor una posicion
	inc dl
	cmp dl, 80
	jb finAvanceColor
	mov dl, 0
	inc dh
finAvanceColor:
	mov ah, 02h
	mov bh, 0
	int 10h

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
imprimirCharColor endp
; imprime una cadena terminada en $ usando el color de BL
; respeta los saltos de linea que tenga el texto
imprimirCadenaColor proc
	push ax
	push bx
	push dx
	push si

	mov si, dx
sigCharCadColor:
	mov dl, [si]
	cmp dl, 24h
	je finCadColor
	cmp dl, 0dh
	je controlCadColor
	cmp dl, 0ah
	je controlCadColor
	call imprimirCharColor
	jmp sigCadColor

controlCadColor:
	call imprimirChar
sigCadColor:
	inc si
	jmp sigCharCadColor

finCadColor:
	pop si
	pop dx
	pop bx
	pop ax
	ret
imprimirCadenaColor endp

leerTecla proc
	mov ah, 1
	int 21h
	ret
leerTecla endp

leerHastaEnter proc
	push ax
	cmp al, 0dh
	je finLeerHastaEnter
seguirLeyendo:
	mov ah, 1
	int 21h
	cmp al, 0dh
	jne seguirLeyendo
finLeerHastaEnter:
	pop ax
	ret
leerHastaEnter endp

saltoLinea proc
	push dx
	mov dl, 0dh
	call imprimirChar
	mov dl, 0ah
	call imprimirChar
	pop dx
	ret
saltoLinea endp

limpiarPantalla proc
	push ax
	push bx
	push cx
	push dx
	mov ax, 0600h ; aca basicamente el sistema interpreta que tiene que desplazar toda la ventana para arriba. AL=00h
	mov bh, 07h
	mov cx, 0000h
	mov dx, 184fh
	int 10h
	mov ah, 02h
	mov bh, 00h
	mov dx, 0000h
	int 10h ; aca el DOS box recibe las coordenadas de la pantalla y limpia todo
	pop dx
	pop cx
	pop bx
	pop ax
	ret ; por que hacemos lo mismo 2 veces? porque el DOS box no asegura que el cursos vuelva donde le necesitamos.
limpiarPantalla endp

imprimirNumero proc ; Un reg2ascii improvisado, no nos pidan barcos de 100 posiciones porque se recontra pudre
	push ax
	push bx
	push dx

	mov ah, 0
	mov bl, 10
	div bl

	cmp al, 0
	je soloUnidad

	add al, 30h
	mov dl, al
	; guardo AX porque en AH esta la unidad del numero
	push ax
	call imprimirChar
	pop ax

soloUnidad:
	add ah, 30h
	mov dl, ah
	call imprimirChar

	pop dx
	pop bx
	pop ax
	ret
imprimirNumero endp

pausa proc
	push ax
	push dx
	mov dx, offset TxtPausa
	call imprimirCadena
	mov ah, 8 ; Es la entrada sin eco que te pide que confirmes el inicio del juego
	int 21h
	pop dx
	pop ax
	ret
pausa endp

end



