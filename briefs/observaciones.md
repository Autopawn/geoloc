El uncapacitated facility location problem es exáctamente el que se trabaja, pero obliga a suplir toda la demanda...? ¡Si!
¿Se daba una cantidad fija de facilities en él?

TODO: Hablar de la desigualdad triangular. ¿Necesaria para un espacio métrico? Sino, agregarla.

TODO: Considerar más opciones que borrar el de peor ganancia del par, ¿Quizá un criterio de desgaste?

TODO: Considerar algoritmos incrementales y on-line ¿Hay una relación?

TODO: Considerar modelos multi-objetivo y relación.

TODO Señalar que este algoritmo se comporta igual que greedy cuando pool_size es 1.

TODO: Señalar que este es como un modelo de covertura _gradual_.

TODO: Buscar sobre problemas de covertura, referencias 79 y 97 de (strategic facility location: A review).

Tomar en cosideración como este modelo se puede reducir al VAN, en las constantes tiene que ir el costo de hacer una instalación más grande (por ser un *uncapacitated*)

Al explicar el modelo se puede representar como un tema de, en vez de tratarse de costo de transporte, sea promedio de accesibilidad de un potencial cliente o beneficiado de la existencia de una instalación.

TODO: Señalar que la necesidad de que la ganancia facility-client esté determinada por una función que decae con la distancia es la que permite el funcionamiento de la optimización del rango de visión (que hace posible usar un criterio de disimilaridad geográfica para mantener soluciones representativas).

TODO: llamar allocation costs al costo de colocar una instalación.

Se puede considerar la interpretación del radio crítico y la eficiencia respecto a él.

Realizar análisis del rango de visión, el decaimiento constante del par de menor dismimilitud es un signo de haberlo elegido correctamente (¿Es un signo o sirve como demostración?), también se puede calcular cual hubiese sido el rango de visión óptimo si se ejecuta con rango de visión infinito y se ve la mayor distancia entre las soluciones de los pares menores.
