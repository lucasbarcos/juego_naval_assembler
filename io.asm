; Libreria de entrada/salida 
.8086
.model small

extrn TxtPausa:byte

.code
public imprimirCadena
public imprimirChar
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
	mov ax, 0600h
	mov bh, 07h
	mov cx, 0000h
	mov dx, 184fh
	int 10h
	mov ah, 02h
	mov bh, 00h
	mov dx, 0000h
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
limpiarPantalla endp

imprimirNumero proc
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
	call imprimirChar

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
	mov ah, 8
	int 21h
	pop dx
	pop ax
	ret
pausa endp

end
