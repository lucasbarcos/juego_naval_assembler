;-----------------------------------------------------------------------
; Programa HIDEKEY que se instala en el vector de interrupciones 09h de
; captura de teclado, un programa que suma 1 al ASCII que proviene y 
; lugo lo pasa a la rutina original
; Se debe generar el ejecutable .COM con los siguientes comandos:
;	tasm HIDEKEY.ASM
;	tlink /t HIDEKEY.OBJ
;-----------------------------------------------------------------------
.8086
.model tiny		;Definicion para generar un archivo .COM
.code
   Org 100h		;Definicion para generar un archivo .COM
Start:
   Jmp main		;Comienza con un salto para dejar la parte residente primero
;------------------------------------------------------------------------
;- Part que queda residente en memoria y contine las ISR
;- de las interrupcion capturadas
;------------------------------------------------------------------------
MissAKey PROC FAR               ;La funcion ISR que atendera la interrupcion capturada
	Jmp continuar
	Letra DB 20h				;se guarda el scan code de la letra a suprimir en la instalac��n
continuar:
	Sti				;Vuelvo a permitir interrupciones
	Push AX
	In AL, 60h		;Leo el SCAN CODE de la tecla presionada desde el puerto 60h
	Nop				;Agrego NOPs para esperar la operaci�n de IN de E/S
	Nop
	Nop
	Nop
	Nop
	Nop
	Nop
	
	Lea bx, Letra
	Cmp AL, CS:[BX]
	Je DoNothing			;Es la letra, salto a "salir sin hacer nada"

	Cmp AL, 56h						;scan code del "<" para reactivar la tecla
	Jne sigo
	Mov dx, word ptr [CS:DespIntXX]	;muevo a DX el offset del viejo puntero de la ISR 09h
	Mov ds, word ptr [CS:SegIntXX]	;muevo a DS el segmento del viejo puntero de la ISR 09h
	Mov AX, 2509h					;restablezco el viejo vector de la ISR 09h
	Int 21h
sigo:
	Pop AX				;Restauro el AX
	Jmp CS:ViejaInt09	;Paso el control a la vieja Int 09h

DoNothing:
   cli				;Inhibo las interrupciones
   In AL, 61h		;Traigo el contenido del puerto comandos del teclado
   Mov AH, AL		;Lo guardo en AH para no perderlo
   Or AL, 80h		;Cambio el bit 7 para decirle al teclado que la interrupci�n fue atendida
   Out 61h, AL		;Escribo el puerto de comandos del teclado
   Mov AL, AH		;Paso el estado anterior del puerto de comandos del teclado al AL
   Out 61h, AL		;Escribo el puerto de comandos del teclado con el comando anterior
   Mov AL, 20h		;Preparo el AL con la direcci�n para programar el PIC
   Out 20h, AL		;Le digo al PIC que puede volver a interrumpir
   Pop AX			;Restauro el AX
   Sti				;Habilito a la CPU para ser interrumpida
   Iret				;retorno
endp

;------------------------------------------------------------------------
; Datos usados dentro de la ISR ya que no hay DS dentro de una ISR
;------------------------------------------------------------------------

ViejaInt09	LABEL   DWORD
DespIntXX	DW		0
SegIntXX	DW		0
KeyMissed	DB		0

FinResidente LABEL BYTE		;Marca el fin de la porcion a dejar residente

;------------------------------------------------------------------------
; Datos a ser usados por el Instalador
;------------------------------------------------------------------------

AskKey		DB "Ingrese la tecla que se suprimira: ",'$'
Message		DB 0dh, 0ah, "Programa Instalado. Tecla suprimida --> "
keyPress	DB 0
Message2	DB 0dh, 0ah, "Si presiona < vuelve a la normalidad."
Tail		DB 0dh, 0ah,'$'

Main:

;------------------------------------------------------------------------
; Se apunta todos los registros de segmentos al mismo lugar CS.
;------------------------------------------------------------------------
    Mov AX, CS
    Mov DS, AX
    Mov ES, AX

    Mov DX, offset AskKey
    Mov AH, 09h
    Int 21h

    Mov AH, 0
    Int 16h

    Mov KeyMissed, AL
    Mov KeyPress, AL
	Lea BX, Letra
    Mov byte ptr [BX], AH

InstalarInt:
    Mov AX, 3509h        ;Obtiene la ISR que esta instalada en la interrupcion
    Int 21h    
         
    Mov DespIntXX, BX    
    Mov SegIntXX, ES

    Mov AX, 2509h	;Coloca la nueva ISR en el vector de interrupciones
    Mov DX, Offset MissAKey 
    Int 21h

MostrarCartel:
    Mov dx, offset Message
    Mov ah, 9h
    Int 21h

DejarResidente:		
    Mov AX, (15+offset FinResidente) ;Al sumar 15, me aseguro 16 bytes (un par�grafo) como m�nimo
    Shr AX, 1 ;Divido la cantidad de bytes por 16 para obtener la cantidad de par�grafos           
    Shr AX, 1 ;ocupados por el c�digo        
    Shr AX, 1
    Shr AX, 1
    Mov DX, AX           
    Mov AX, 3100h ;y termina sin error 0, dejando el programa residente
    Int 21h
end Start
