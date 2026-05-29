# juego_naval_assembler
BATALLA NAVAL - VERSION CON CARGA DE BARCOS

Archivos:
- main.asm: programa principal.
- io.asm: rutinas propias de entrada/salida.
- tab.asm: rutinas propias del tablero y del juego.

Como se juega:
1. El tablero es de 10x10.
2. Primero se cargan los barcos en el mapa.
3. Cada barco pide fila inicial, columna inicial y orientacion.
4. La orientacion puede ser H horizontal o V vertical.
5. Despues empieza la etapa de disparos.
6. X significa tocado.
7. O significa agua.
8. ~ significa que todavia no se disparo ahi.

Condicion de victoria:
- Hay 6 barcos escondidos.
- El jugador gana si unde los 6 barcos.

Condicion de derrota:
- El jugador pierde si se queda sin intentos.

Barcos:
- 1 barco de 5 casillas
- 1 barco de 4 casillas
- 2 barco de 3 casillas
- 2 barcos de 2 casillas

Compilacion sugerida con TASM:
	tasm main.asm
	tasm io.asm
	tasm tab.asm
	tlink main+io+tab,main
	main.exe
Compilacion rapida:
	compi
