; LIBRERIA DE SONIDOS DEL JUEGO
;
; Este archivo crea musica y efectos con el parlante interno de la PC.
; Cada sonido se arma con frecuencias y tiempos.
;
; COMO FUNCIONA:
; 1. El puerto 43h configura el temporizador de la PC.
; 2. El puerto 42h recibe el divisor que determina la frecuencia.
; 3. El puerto 61h enciende y apaga el parlante.
; 4. INT 1Ah se usa como reloj para controlar la duracion de cada nota.
; 5. tocarTono es la rutina comun que usan todos los efectos.
; 6. apagarParlante y silencioCorto evitan que quede un ruido residual.
;
; En NotasWin estan las frecuencias de la victoria y en DurWin esta
; la duracion correspondiente a cada nota. CantWin indica cuantas hay.

.8086
.model small

.data
	; melodia aproximada extraida del audio de victoria
	NotasWin dw 1208,1280,1437,1612,1810,1918,2152,1208,9664,2416
	DurWin db 3,2,2,1,1,2,1,3,2,12
	CantWin equ 10

.code
public sonidoAgua
public sonidoTocado
public sonidoHundido
public sonidoInicio
public sonidoCarga
public sonidoVictoria
public sonidoDerrota

; fuerza el apagado del parlante para evitar ruido residual
apagarParlante proc
	push ax
	in al, 61h
	and al, 0FCh
	out 61h, al
	pop ax
	ret
apagarParlante endp

; deja un tick de silencio despues de un efecto corto
silencioCorto proc
	push ax
	push dx
	push si
	call apagarParlante
	mov ah, 00h
	int 1Ah
	mov si, dx
esperaSilencio:
	mov ah, 00h
	int 1Ah
	mov ax, dx
	sub ax, si
	cmp ax, 1
	jb esperaSilencio
	call apagarParlante
	pop si
	pop dx
	pop ax
	ret
silencioCorto endp

; AX recibe el divisor de frecuencia y CX la duracion en ticks.
; El reloj tiene aproximadamente 18 ticks por segundo.
tocarTono proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	; apago cualquier tono anterior antes de programar uno nuevo
	call apagarParlante

	mov bx, ax
	mov di, cx

	; preparo el temporizador para generar el tono
	mov al, 0B6h
	out 43h, al
	mov ax, bx
	out 42h, al
	mov al, ah
	out 42h, al

	; enciendo el parlante
	in al, 61h
	or al, 03h
	out 61h, al

	; guardo el tick inicial del reloj del BIOS
	mov ah, 00h
	int 1Ah
	mov si, dx

esperaTono:
	mov ah, 00h
	int 1Ah
	mov ax, dx
	sub ax, si
	cmp ax, di
	jb esperaTono

	; apago el parlante al terminar la duracion
	call apagarParlante

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
tocarTono endp

; tono grave y corto para agua
sonidoAgua proc
	mov ax, 4773
	mov cx, 3
	call tocarTono
	ret
sonidoAgua endp

; tono agudo y limpio para un acierto
sonidoTocado proc
	; dos ticks alcanzan para reconocer el acierto sin dejar zumbido
	mov ax, 995
	mov cx, 2
	call tocarTono
	; este silencio evita el ruido electrico que quedaba al cortar el tono
	call silencioCorto
	ret
sonidoTocado endp

; secuencia descendente de aproximadamente 2,5 segundos
sonidoHundido proc
	mov ax, 1193
	mov cx, 12
	call tocarTono
	mov ax, 1594
	mov cx, 14
	call tocarTono
	mov ax, 2386
	mov cx, 19
	call tocarTono
	ret
sonidoHundido endp

; melodia completa para la pantalla del dibujo inicial
sonidoInicio proc
	mov ax, 3043
	mov cx, 5
	call tocarTono
	mov ax, 2416
	mov cx, 5
	call tocarTono
	mov ax, 2032
	mov cx, 5
	call tocarTono
	mov ax, 1521
	mov cx, 10
	call tocarTono
	ret
sonidoInicio endp

; aviso corto antes de comenzar a colocar los barcos
sonidoCarga proc
	mov ax, 3619
	mov cx, 4
	call tocarTono
	mov ax, 3043
	mov cx, 4
	call tocarTono
	mov ax, 2711
	mov cx, 7
	call tocarTono
	ret
sonidoCarga endp

; reproduce la melodia que se saco del archivo de audio
sonidoVictoria proc
	push ax
	push bx
	push cx
	push si

	mov si, 0
	mov bx, 0

sigNotaWin:
	cmp bx, CantWin
	jae finWin
	mov ax, NotasWin[si]
	mov cl, DurWin[bx]
	mov ch, 0
	call tocarTono
	add si, 2
	inc bx
	jmp sigNotaWin

finWin:
	pop si
	pop cx
	pop bx
	pop ax
	ret
sonidoVictoria endp

; melodia descendente para la derrota
sonidoDerrota proc
	mov ax, 2032
	mov cx, 7
	call tocarTono
	mov ax, 2711
	mov cx, 7
	call tocarTono
	mov ax, 3619
	mov cx, 10
	call tocarTono
	ret
sonidoDerrota endp

end

