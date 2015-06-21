# langton_ant
=Simulación de la hormiga de Langton=

El problema está implementado en javascript y en vala, para poder compilarlo en vala es necesario tener instalo el compilador de vala, valac, las dependicas de vala y los ficheros fuentes de la librería gráfica SDL, en ubuntu se instalan con el siguiente comando:

```sudo apt-get install libsdl1.2-dev libsdl-gfx1.2-dev```

una vez instalado lo anterior basta con ejecutar el siguiente comando para compilar el código:

```valac --pkg sdl --pkg sdl-gfx -X -lSDL_gfx -o langton LangtonAnt.vala```
