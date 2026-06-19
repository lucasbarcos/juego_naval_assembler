BATALLA NAVAL EN ASSEMBLER 8086
================================

DESCRIPCION
Juego de Batalla Naval para DOS hecho con TASM y librerias propias.
El tablero tiene 10 filas (A-J), 10 columnas (1-10) y seis barcos.
El mouse se usa para elegir casillas y el teclado para indicar H o V.


ARCHIVOS DEL PROYECTO
main.asm
  Programa principal. Guarda las variables compartidas y controla
  la portada, la carga de barcos, los turnos, la victoria y la derrota.

io.asm
  Libreria de entrada y salida. Imprime texto y numeros, lee teclas,
  usa colores, limpia la pantalla y realiza las pausas.

tab.asm
  Libreria del tablero. Coloca y valida barcos, imprime los mapas,
  verifica disparos y registra los barcos hundidos.

mouse.asm
  Libreria del mouse. Convierte un clic en una fila y una columna.
  Tambien rechaza los clics fuera de las casillas.

son.asm
  Libreria de sonido. Genera efectos y melodias con el temporizador
  y el parlante interno de la PC.

graf.asm
  Portada grafica. Usa el modo VGA 13h para dibujar el barco, el mar,
  el cielo y los textos directamente en la memoria de video.

compi.bat
  Compila todos los ASM, enlaza los OBJ y ejecuta MAIN.EXE.


COMO SE RELACIONAN
main.asm llama a procedimientos publicos de las cinco librerias.
Las instrucciones EXTRN permiten usar un procedimiento o dato que esta
en otro archivo. Las instrucciones PUBLIC permiten compartirlo.
TLINK junta todos los archivos OBJ para formar un solo ejecutable.


BARCOS
- 1 barco de 5 casillas.
- 1 barco de 4 casillas.
- 2 barcos de 3 casillas.
- 2 barcos de 2 casillas.
- Total ocupado: 19 casillas.


COMO SE JUEGA
1. Se muestra la portada grafica y su sonido.
2. Se colocan los seis barcos.
3. El mouse elige la casilla inicial de cada barco.
4. El teclado indica H para horizontal o V para vertical.
5. Al terminar la carga comienza la etapa de disparos.
6. X significa tocado, O significa agua y ~ significa sin disparar.
7. Un disparo al agua descuenta un intento.
8. Un acierto o un disparo repetido no descuenta intentos.


FINAL DEL JUEGO
Victoria:
  Se consigue al acertar las 19 casillas ocupadas por los barcos.

Derrota:
  Ocurre cuando los intentos llegan a cero. En ese momento se muestran
  las posiciones reales de todos los barcos.


COMPILACION RAPIDA
Desde C:\Tasm 1.4\Tasm\naval ejecutar:

  compi

El archivo compi.bat ejecuta estos comandos:

  tasm main
  tasm io
  tasm tab
  tasm mouse
  tasm son
  tasm graf
  tlink main+io+tab+mouse+son+graf,main
  main


INTERRUPCIONES Y HARDWARE USADOS
INT 10h = video, cursor, colores y cambio de modo.
INT 21h = impresion de texto, teclado y finalizacion del programa.
INT 33h = control del mouse.
INT 1Ah = reloj usado para medir la duracion de los sonidos.
Puertos 42h, 43h y 61h = temporizador y parlante interno.


IMPORTANTE AL MODIFICAR
- Si cambia el tablero, revisar TAM, TOTAL_CAS, cabecera y el mouse.
- Si cambian los barcos, revisar CANTBAR, barcos, golpes, hundidos
  y TOTAL_BAR.
- No quitar las validaciones de limites de tab.asm.
- No quitar las validaciones de espacios negros de mouse.asm.
- Todos los modulos deben aparecer en la orden de TLINK.
