El problema común de la ubicación de plantas determina que plantas abrir de un conjunto de posibles para satisfacer la demanda de un conjunto de clientes. Sin embargo, los costos de inversión de la solución óptima pueden exceder un límite en la práctica. Por lo que se considera un modelo bicriterio que balancea los costos de inversión y los costos operativos, se investiga la integer-friendliness de la relajación ĹP.

En el modelo original (Balinski) se busca servir una serie de clientes a un costo mínimo, las asunciones de este modelo. (Brimberg y Revelle) sugirieron un modelo bicriterio para estudiar el tradeoff entre el costo total y la proporción del mercado servida.

**IMPORTANTE:** Servir a todos los clientes se llama `serve all comers`.

Se escriben dos modelos, el primero es el plant location problem con objetivos de costo total mínimo y el maximum return on investment.kj

Brimberg y ReVelle abordan el problema de los clientes que no conviene alcanzar, otra vez el buscado paper: _A multi-facility location model with partial satisfaction of demand_.

Habla sobre la resolución de estos problemas usando weighting method, cada iteración de este último se puede resolver con algoritmos especializados como DUALOC, Lagrangean-based methos o incluso LP con branch-and-bound, que aparentemente es *integer-friendly*.

TODO: Es importante entender si estas resoluciones ^ sirven para covertura parcial o no, o si aun no sirviendo, la solución con covertura total es óptima para el problema de covertura parcial.

TODO: Comprobar cómo se comporta la LP con branch-and-bound con problemas como este.

NOTE: Es importante nombrar la cantidad de datos que se están manejando, por lo visto en este paper se consideran problemas bastante más pequeños.

"However, the removal of the 'serve all comers' equierement is expectos to improve the integer friendliness of the problem structure. Otra vez el buscado paper: _A multi-facility location model with partial satisfaction of demand_.
