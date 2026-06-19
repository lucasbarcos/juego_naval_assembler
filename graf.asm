; Portada grafica: barco en un atardecer pixel art.
; Esta es la portada grafica del proyecto.
; El modelo original hecho con texto sigue guardado en main.asm.
;
; COMO FUNCIONA:
; 1. Se activa el modo VGA 13h de 320x200 pixels y 256 colores.
; 2. ES apunta a A000h, que es el segmento de memoria de video.
; 3. dibujarLinea pinta una fila de pixels directamente en esa memoria.
; 4. dibujarRect repite lineas para formar rectangulos.
; 5. Los rectangulos forman cielo, sol, nubes, mar y partes del barco.
; 6. Las velas usan ciclos que cambian el ancho para formar triangulos.
; 7. cerrarGraf espera una tecla y restaura el modo texto 80x25.
;
; VARIABLES PARA DIBUJAR:
; grafX = coordenada horizontal inicial, desde 0 hasta 319.
; grafY = coordenada vertical inicial, desde 0 hasta 199.
; grafAncho = cantidad de pixels que tiene una linea horizontal.
; grafColor = numero de color de la paleta VGA.
; grafAlto = cantidad de filas que se repiten para formar un rectangulo.
;
; COLORES PRINCIPALES:
; 0 negro, 1 azul oscuro, 3 celeste oscuro, 5 violeta, 6 marron,
; 8 gris oscuro, 9 azul, 11 celeste, 12 rojo, 13 rosa,
; 14 amarillo y 15 blanco.
;
; IMPORTANTE: si se cambia la resolucion, tambien cambia el calculo
; fila * 320 + columna que usa dibujarLinea para encontrar cada pixel.

.8086                  ; instrucciones compatibles con 8086
.model small            ; un segmento de codigo y uno de datos


; DATOS QUE UTILIZA LA PORTADA
.data
	; texto del titulo, termina en cero para que imprimirTextoGraf sepa donde parar
	TituloGraf db "BATALLA NAVAL",0
	; aviso que aparece en la parte inferior
	TeclaGraf db "PRESIONA UNA TECLA",0
	; posicion y formato de la proxima linea o rectangulo
	grafX dw 0              ; columna inicial
	grafY dw 0              ; fila inicial
	grafAncho dw 0            ; ancho en pixels
	grafColor db 0            ; color VGA
	grafAlto dw 0              ; altura del rectangulo


; PROCEDIMIENTOS DE LA PORTADA
.code
; Se hacen publicos para poder llamarlos desde main.asm.
public mostrarGraf
public cerrarGraf

; dibuja una linea horizontal en la memoria VGA
; Usa: posicion = grafY * 320 + grafX.
; Luego escribe grafAncho veces el color grafColor usando REP STOSB.
dibujarLinea proc
	push ax
	push bx
	push cx
	push dx
	push di

	mov ax, grafY
	mov bx, 320
	mul bx
	add ax, grafX
	mov di, ax
	mov cx, grafAncho
	mov al, grafColor
	rep stosb

	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret
dibujarLinea endp

; repite una linea para formar un rectangulo
; Repite dibujarLinea grafAlto veces y aumenta grafY en cada vuelta.
dibujarRect proc
	push ax
	push bx
	push cx
	push dx

	mov cx, grafAlto
sigFilaRect:
	call dibujarLinea            ; dibuja una sola linea con los valores de arriba
	inc grafY                     ; baja un pixel para la siguiente linea
	loop sigFilaRect

	pop dx
	pop cx
	pop bx
	pop ax
	ret
dibujarRect endp

; texto terminado en 0 para modo grafico
; Recibe DH=fila, DL=columna, SI=texto y BL=color.
; Usa int 10h para colocar el cursor e imprimir cada caracter.
imprimirTextoGraf proc
	push ax
	push bx
	push dx
	push si

	mov ah, 02h
	mov bh, 0
	int 10h
sigTextoGraf:
	mov al, [si]
	cmp al, 0
	je finTextoGraf
	mov ah, 0Eh
	mov bh, 0
	int 10h
	inc si
	jmp sigTextoGraf
finTextoGraf:
	pop si
	pop dx
	pop bx
	pop ax
	ret
imprimirTextoGraf endp

; Procedimiento principal: cambia a modo grafico y arma toda la escena.
mostrarGraf proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es

	mov ax, 0013h
	int 10h
	mov ax, 0A000h
	mov es, ax

	; CIELO: rectangulos de colores forman el degradado del atardecer
	mov grafX, 0              ; X: posicion horizontal desde la izquierda
	mov grafY, 0              ; Y: posicion vertical desde arriba
	mov grafAncho, 320          ; ancho de la figura en pixels
	mov grafColor, 5          ; color 5 = violeta
	mov grafAlto, 28           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafColor, 13          ; color 13 = rosa
	mov grafAlto, 26           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafColor, 12          ; color 12 = rojo/naranja
	mov grafAlto, 30           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafColor, 14          ; color 14 = amarillo
	mov grafAlto, 62           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; SOL: bandas que se ensanchan y achican simulan un circulo
	mov grafX, 139              ; X: posicion horizontal desde la izquierda
	mov grafY, 35              ; Y: posicion vertical desde arriba
	mov grafAncho, 42          ; ancho de la figura en pixels
	mov grafColor, 12          ; color 12 = rojo/naranja
	mov grafAlto, 5           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 125              ; X: posicion horizontal desde la izquierda
	mov grafAncho, 70          ; ancho de la figura en pixels
	mov grafAlto, 7           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 112              ; X: posicion horizontal desde la izquierda
	mov grafAncho, 96          ; ancho de la figura en pixels
	mov grafAlto, 9           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 102              ; X: posicion horizontal desde la izquierda
	mov grafAncho, 116          ; ancho de la figura en pixels
	mov grafAlto, 24           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 94              ; X: posicion horizontal desde la izquierda
	mov grafAncho, 132          ; ancho de la figura en pixels
	mov grafColor, 14          ; color 14 = amarillo
	mov grafAlto, 35           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 102              ; X: posicion horizontal desde la izquierda
	mov grafAncho, 116          ; ancho de la figura en pixels
	mov grafAlto, 16           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 115              ; X: posicion horizontal desde la izquierda
	mov grafAncho, 90          ; ancho de la figura en pixels
	mov grafAlto, 10           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; NUBES IZQUIERDAS: rectangulos superpuestos forman la silueta
	mov grafColor, 3          ; color 3 = celeste oscuro
	mov grafX, 5              ; X: posicion horizontal desde la izquierda
	mov grafY, 72              ; Y: posicion vertical desde arriba
	mov grafAncho, 82          ; ancho de la figura en pixels
	mov grafAlto, 5           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 15              ; X: posicion horizontal desde la izquierda
	mov grafY, 63              ; Y: posicion vertical desde arriba
	mov grafAncho, 55          ; ancho de la figura en pixels
	mov grafAlto, 9           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 27              ; X: posicion horizontal desde la izquierda
	mov grafY, 53              ; Y: posicion vertical desde arriba
	mov grafAncho, 30          ; ancho de la figura en pixels
	mov grafAlto, 10           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 42              ; X: posicion horizontal desde la izquierda
	mov grafY, 46              ; Y: posicion vertical desde arriba
	mov grafAncho, 14          ; ancho de la figura en pixels
	mov grafAlto, 7           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 0              ; X: posicion horizontal desde la izquierda
	mov grafY, 91              ; Y: posicion vertical desde arriba
	mov grafAncho, 105          ; ancho de la figura en pixels
	mov grafAlto, 7           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 18              ; X: posicion horizontal desde la izquierda
	mov grafY, 82              ; Y: posicion vertical desde arriba
	mov grafAncho, 75          ; ancho de la figura en pixels
	mov grafAlto, 9           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; NUBES DERECHAS: se usa la misma tecnica del lado contrario
	mov grafX, 257              ; X: posicion horizontal desde la izquierda
	mov grafY, 49              ; Y: posicion vertical desde arriba
	mov grafAncho, 63          ; ancho de la figura en pixels
	mov grafAlto, 7           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 270              ; X: posicion horizontal desde la izquierda
	mov grafY, 38              ; Y: posicion vertical desde arriba
	mov grafAncho, 45          ; ancho de la figura en pixels
	mov grafAlto, 11           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 282              ; X: posicion horizontal desde la izquierda
	mov grafY, 27              ; Y: posicion vertical desde arriba
	mov grafAncho, 24          ; ancho de la figura en pixels
	mov grafAlto, 11           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 244              ; X: posicion horizontal desde la izquierda
	mov grafY, 92              ; Y: posicion vertical desde arriba
	mov grafAncho, 76          ; ancho de la figura en pixels
	mov grafAlto, 7           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 264              ; X: posicion horizontal desde la izquierda
	mov grafY, 77              ; Y: posicion vertical desde arriba
	mov grafAncho, 56          ; ancho de la figura en pixels
	mov grafAlto, 15           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; BRILLOS: lineas amarillas representan la luz sobre las nubes
	mov grafColor, 14          ; color 14 = amarillo
	mov grafX, 17              ; X: posicion horizontal desde la izquierda
	mov grafY, 62              ; Y: posicion vertical desde arriba
	mov grafAncho, 23          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 44              ; X: posicion horizontal desde la izquierda
	mov grafY, 45              ; Y: posicion vertical desde arriba
	mov grafAncho, 13          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 274              ; X: posicion horizontal desde la izquierda
	mov grafY, 37              ; Y: posicion vertical desde arriba
	mov grafAncho, 16          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 287              ; X: posicion horizontal desde la izquierda
	mov grafY, 26              ; Y: posicion vertical desde arriba
	mov grafAncho, 12          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; MAR: franjas azul oscuro, azul y negro ocupan la parte inferior
	mov grafX, 0              ; X: posicion horizontal desde la izquierda
	mov grafY, 146              ; Y: posicion vertical desde arriba
	mov grafAncho, 320          ; ancho de la figura en pixels
	mov grafColor, 3          ; color 3 = celeste oscuro
	mov grafAlto, 17           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafColor, 9          ; color 9 = azul
	mov grafAlto, 19           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafColor, 1          ; color 1 = azul oscuro
	mov grafAlto, 18           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafColor, 0          ; color 0 = negro
	mov grafAlto, 17           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; OLAS: lineas blancas y celestes agregan espuma y movimiento
	mov grafColor, 15          ; color 15 = blanco
	mov grafX, 0              ; X: posicion horizontal desde la izquierda
	mov grafY, 150              ; Y: posicion vertical desde arriba
	mov grafAncho, 42          ; ancho de la figura en pixels
	mov grafAlto, 2           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 58              ; X: posicion horizontal desde la izquierda
	mov grafY, 155              ; Y: posicion vertical desde arriba
	mov grafAncho, 48          ; ancho de la figura en pixels
	mov grafAlto, 2           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 220              ; X: posicion horizontal desde la izquierda
	mov grafY, 151              ; Y: posicion vertical desde arriba
	mov grafAncho, 54          ; ancho de la figura en pixels
	mov grafAlto, 2           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 285              ; X: posicion horizontal desde la izquierda
	mov grafY, 159              ; Y: posicion vertical desde arriba
	mov grafAncho, 35          ; ancho de la figura en pixels
	mov grafAlto, 2           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafColor, 11          ; color 11 = celeste
	mov grafX, 20              ; X: posicion horizontal desde la izquierda
	mov grafY, 169              ; Y: posicion vertical desde arriba
	mov grafAncho, 70          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 116              ; X: posicion horizontal desde la izquierda
	mov grafY, 176              ; Y: posicion vertical desde arriba
	mov grafAncho, 55          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 235              ; X: posicion horizontal desde la izquierda
	mov grafY, 173              ; Y: posicion vertical desde arriba
	mov grafAncho, 66          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; MASTIL PRINCIPAL: borde negro y centro marron
	mov grafX, 176              ; X: posicion horizontal desde la izquierda
	mov grafY, 65              ; Y: posicion vertical desde arriba
	mov grafAncho, 7          ; ancho de la figura en pixels
	mov grafColor, 0          ; color 0 = negro
	mov grafAlto, 87           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 178              ; X: posicion horizontal desde la izquierda
	mov grafY, 67              ; Y: posicion vertical desde arriba
	mov grafAncho, 3          ; ancho de la figura en pixels
	mov grafColor, 6          ; color 6 = marron
	mov grafAlto, 83           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; MASTIL TRASERO: mas corto porque esta detras del principal
	mov grafX, 202              ; X: posicion horizontal desde la izquierda
	mov grafY, 82              ; Y: posicion vertical desde arriba
	mov grafAncho, 5          ; ancho de la figura en pixels
	mov grafColor, 0          ; color 0 = negro
	mov grafAlto, 69           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 204              ; X: posicion horizontal desde la izquierda
	mov grafY, 84              ; Y: posicion vertical desde arriba
	mov grafAncho, 2          ; ancho de la figura en pixels
	mov grafColor, 6          ; color 6 = marron
	mov grafAlto, 65           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; VELA IZQUIERDA: el ciclo aumenta el ancho y mueve X hacia la izquierda
	; de esa manera se forma un triangulo sin usar una imagen externa
	mov si, 82
velaIzq:
	mov ax, si
	sub ax, 82
	mov bx, 2
	div bl
	mov ah, 0
	mov bx, 176
	sub bx, ax
	mov grafX, bx              ; X: posicion horizontal desde la izquierda
	mov grafAncho, ax          ; ancho de la figura en pixels
	add grafAncho, 3
	mov grafY, si              ; Y: posicion vertical desde arriba
	mov grafColor, 8          ; color 8 = gris oscuro
	call dibujarLinea            ; dibuja una sola linea con los valores de arriba
	inc si
	cmp si, 137
	jb velaIzq

	; VELA DERECHA: aumenta el ancho pero conserva el borde izquierdo
	mov si, 88
velaDer:
	mov ax, si
	sub ax, 88
	mov bx, 2
	div bl
	mov ah, 0
	mov grafX, 184              ; X: posicion horizontal desde la izquierda
	mov grafAncho, ax          ; ancho de la figura en pixels
	add grafAncho, 4
	mov grafY, si              ; Y: posicion vertical desde arriba
	mov grafColor, 8          ; color 8 = gris oscuro
	call dibujarLinea            ; dibuja una sola linea con los valores de arriba
	inc si
	cmp si, 137
	jb velaDer

	; VELAS TRASERAS: rectangulos pequenos agregan profundidad
	mov grafX, 207              ; X: posicion horizontal desde la izquierda
	mov grafY, 93              ; Y: posicion vertical desde arriba
	mov grafAncho, 27          ; ancho de la figura en pixels
	mov grafColor, 8          ; color 8 = gris oscuro
	mov grafAlto, 16           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 207              ; X: posicion horizontal desde la izquierda
	mov grafY, 113              ; Y: posicion vertical desde arriba
	mov grafAncho, 22          ; ancho de la figura en pixels
	mov grafAlto, 17           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; CUBIERTA Y CABINA: negro para bordes y azul para relleno
	mov grafX, 164              ; X: posicion horizontal desde la izquierda
	mov grafY, 108              ; Y: posicion vertical desde arriba
	mov grafAncho, 56          ; ancho de la figura en pixels
	mov grafColor, 0          ; color 0 = negro
	mov grafAlto, 5           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 169              ; X: posicion horizontal desde la izquierda
	mov grafY, 101              ; Y: posicion vertical desde arriba
	mov grafAncho, 43          ; ancho de la figura en pixels
	mov grafColor, 3          ; color 3 = celeste oscuro
	mov grafAlto, 7           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 168              ; X: posicion horizontal desde la izquierda
	mov grafY, 118              ; Y: posicion vertical desde arriba
	mov grafAncho, 60          ; ancho de la figura en pixels
	mov grafColor, 0          ; color 0 = negro
	mov grafAlto, 5           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 174              ; X: posicion horizontal desde la izquierda
	mov grafY, 123              ; Y: posicion vertical desde arriba
	mov grafAncho, 48          ; ancho de la figura en pixels
	mov grafColor, 3          ; color 3 = celeste oscuro
	mov grafAlto, 12           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; BANDERA: primero se dibuja el borde negro y despues el centro naranja
	mov grafX, 178              ; X: posicion horizontal desde la izquierda
	mov grafY, 62              ; Y: posicion vertical desde arriba
	mov grafAncho, 22          ; ancho de la figura en pixels
	mov grafColor, 0          ; color 0 = negro
	mov grafAlto, 4           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 181              ; X: posicion horizontal desde la izquierda
	mov grafY, 63              ; Y: posicion vertical desde arriba
	mov grafAncho, 16          ; ancho de la figura en pixels
	mov grafColor, 12          ; color 12 = rojo/naranja
	mov grafAlto, 2           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; CASCO: borde negro, madera marron y base inferior negra
	mov grafX, 145              ; X: posicion horizontal desde la izquierda
	mov grafY, 137              ; Y: posicion vertical desde arriba
	mov grafAncho, 94          ; ancho de la figura en pixels
	mov grafColor, 0          ; color 0 = negro
	mov grafAlto, 8           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 151              ; X: posicion horizontal desde la izquierda
	mov grafY, 145              ; Y: posicion vertical desde arriba
	mov grafAncho, 82          ; ancho de la figura en pixels
	mov grafColor, 6          ; color 6 = marron
	mov grafAlto, 12           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 160              ; X: posicion horizontal desde la izquierda
	mov grafY, 157              ; Y: posicion vertical desde arriba
	mov grafAncho, 64          ; ancho de la figura en pixels
	mov grafColor, 0          ; color 0 = negro
	mov grafAlto, 8           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; VENTANAS: cuatro rectangulos amarillos pequenos
	mov grafX, 171              ; X: posicion horizontal desde la izquierda
	mov grafY, 147              ; Y: posicion vertical desde arriba
	mov grafAncho, 5          ; ancho de la figura en pixels
	mov grafColor, 14          ; color 14 = amarillo
	mov grafAlto, 4           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 184              ; X: posicion horizontal desde la izquierda
	mov grafY, 147              ; Y: posicion vertical desde arriba
	mov grafAncho, 5          ; ancho de la figura en pixels
	mov grafAlto, 4           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 197              ; X: posicion horizontal desde la izquierda
	mov grafY, 147              ; Y: posicion vertical desde arriba
	mov grafAncho, 5          ; ancho de la figura en pixels
	mov grafAlto, 4           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 210              ; X: posicion horizontal desde la izquierda
	mov grafY, 147              ; Y: posicion vertical desde arriba
	mov grafAncho, 5          ; ancho de la figura en pixels
	mov grafAlto, 4           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; ESPUMA: lineas a ambos lados hacen que el barco parezca avanzar
	mov grafColor, 15          ; color 15 = blanco
	mov grafX, 126              ; X: posicion horizontal desde la izquierda
	mov grafY, 157              ; Y: posicion vertical desde arriba
	mov grafAncho, 31          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 228              ; X: posicion horizontal desde la izquierda
	mov grafY, 158              ; Y: posicion vertical desde arriba
	mov grafAncho, 35          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafColor, 11          ; color 11 = celeste
	mov grafX, 135              ; X: posicion horizontal desde la izquierda
	mov grafY, 162              ; Y: posicion vertical desde arriba
	mov grafAncho, 31          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba
	mov grafX, 220              ; X: posicion horizontal desde la izquierda
	mov grafY, 163              ; Y: posicion vertical desde arriba
	mov grafAncho, 34          ; ancho de la figura en pixels
	mov grafAlto, 3           ; alto de la figura en pixels
	call dibujarRect             ; dibuja el rectangulo con los valores de arriba

	; TEXTOS: imprimirTextoGraf usa coordenadas de caracteres, no de pixels
	mov dh, 1                   ; fila de texto donde aparece el mensaje
	mov dl, 13                   ; columna de texto donde aparece el mensaje
	mov si, offset TituloGraf
	mov bl, 14                   ; color del texto: amarillo
	call imprimirTextoGraf       ; imprime el texto en la posicion elegida
	mov dh, 23                   ; fila de texto donde aparece el mensaje
	mov dl, 10                   ; columna de texto donde aparece el mensaje
	mov si, offset TeclaGraf
	mov bl, 15                   ; color del texto: blanco
	call imprimirTextoGraf       ; imprime el texto en la posicion elegida

	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
mostrarGraf endp

; Espera una tecla con int 16h y vuelve al modo texto con int 10h.
cerrarGraf proc
	mov ah, 00h
	int 16h
	mov ax, 0003h
	int 10h
	ret
cerrarGraf endp

end



