# Colonia

Un juego 2D sobre una hormiga que debe abastecer un nido fragmentado antes de que llegue el invierno.

## Language

**Comida**:
El único recurso de victoria. Objeto físico: la Hormiga carga uno a la vez, en las mandíbulas. Con 5 en el Almacén antes del Invierno, se gana.
_Avoid_: alimento, recurso, fragmento, hoja, stack

**Almacén**:
La zona del Hormiguero donde se deposita Comida. Cinco piezas aquí son la victoria.
_Avoid_: depósito, almacén de herramientas, storage

**Invierno**:
La fecha límite. Se lee en Afuera y en el Hormiguero (luz, viento, menos vida, frío) hasta que llega y la partida termina.
_Avoid_: timer, reloj, barra de esquina, “demasiado tarde”

**Hormiguero**:
El nido dañado. Está fragmentado y se queda así: ninguna zona se reconstruye.
_Avoid_: colonia (como lugar), mapa, base

**Zona**:
Una parte visualmente distinta del Hormiguero.
_Avoid_: habitación, room, nivel, pantalla

**Fragmentado**:
El estado del Hormiguero. Es una cualidad del espacio, no un objeto que se recoge.
_Avoid_: fragmento, pieza, parte de herramienta

**Hormiga**:
El único cuerpo que controla la jugadora. Una obrera de una colonia que ya no está completa.
_Avoid_: jugador, personaje, party, cooperativo

**Reina**:
La figura ausente. No es un objetivo ni un personaje.
_Avoid_: boss, NPC, objetivo final

**Cámara de la reina**:
Zona visitable y vacía. No se deposita Comida. No se repara.
_Avoid_: spawn, hub, trono

**Derrumbada**:
Zona que no se atraviesa. Se ve y se oye. Corta el camino y empuja de nuevo al exterior.
_Avoid_: pared invisible, puerta con llave, obstáculo con vida

**Larva**:
Vida que espera en su zona. Cambia al depositar Comida. No es recurso de victoria.
_Avoid_: bebé (como ítem), NPC de misión

**Victoria**:
Cinco Comidas en el Almacén antes del Invierno. Las Larvas se agitan. El Hormiguero sigue fragmentado. La Reina no vuelve.
_Avoid_: nido reparado, ending bueno, reconstrucción

**Derrota**:
El Invierno llega (blanco) con menos de cinco Comidas en el Almacén. Las Larvas no se mueven.
_Avoid_: game over por Energía, muerte de la Hormiga

**Energía**:
Lo que la Hormiga gasta fuera del Hormiguero. Al agotarse no muere: se arrastra y suelta la Comida.
_Avoid_: vida, HP, stamina como historia

**Descanso**:
Zona que restaura Energía. El Invierno no se detiene mientras descansa.
_Avoid_: save point, cama infinita, pausa

**Afuera**:
El único exterior. Suelo del bosque a escala de Hormiga. Ahí vive la Comida.
_Avoid_: mundo, overworld, biomas, nivel 2
