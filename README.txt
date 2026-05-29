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
- Hay 18 partes de barcos escondidas.
- El jugador gana si encuentra las 18.

Condicion de derrota:
- El jugador pierde si se queda sin intentos.

Barcos disponibles:
- 1 barco de 5 casillas
- 1 barco de 4 casillas
- 1 barco de 3 casillas
- 3 barcos de 2 casillas

Compilacion sugerida con TASM:
	tasm main.asm
	tasm io.asm
	tasm tab.asm
	tlink main+io+tab,main
	main.exe

Ideas para ampliar:
- Agregar menu principal.
- Agregar dificultad facil/media/dificil.
- Dejar que el usuario cargue los barcos.
- Agregar modo dos jugadores.
- Poner barcos aleatorios usando la hora del sistema como semilla.
