```
@article{revelle2005location,
  title={Location analysis: A synthesis and survey},
  author={ReVelle, Charles S and Eiselt, Horst A},
  journal={European journal of operational research},
  volume={165},
  number={1},
  pages={1--19},
  year={2005},
  publisher={Elsevier}
}
```

# Principales:

La ciencia del *facility sitting* (o *location*) involucra una gran cantidad de problemas porque estos tienen varias peculiaridades, entre ellas los desafíos de la **presencia de no-linealidades** y **presencia de variables zero-uno**.
<!-- ^ La última vuelve a algunos NP-Completos -->

*Location análisis*, es el campo, se divide en:
- **Location problems**: Instalaciones pequeñas, sin interacción necesariamente.
- **Layout problems**: Instalaciones de gran alcance, las interacciones son la norma.

Domschke and Drexl (1985) listan más de 1500 referencias.

Problemas están compuestos de **clientes**, **facilities**, **espacio** (no necesariamente geométrico) y **métrica de distancia**.
<!-- ^ Feature space es un ejemplo de espacio no necesariamente relacionado con la geometría -->

A diferencia de, por ejemplo, los routing problems, estos problemas tienen múltiples objetivos.

Diferenciación por espacio 1:
- Espacio *d-dimensional*
- Network location (sobre grafos)

Diferenciación por espacio 2:
- **Continuos**: Emplazados en cualquier lugar del plano o red (problemas no lineales).
- **Discretos**: Emplazados sólo en posiciones fijas (problemas *uno-zero*).

La distancia utilizada también es importante (Love et al. lista varias).

Diferenciación de objetivos:
- "pull" objetives (min distancia máxima, min costo transporte).
- "push" objetives.
- Balancing objectives (los que buscan equidad generalmente)

Diferenciación por cantidad de facilities:
- Sólo 1 facility.
- Varias (p) facilities.
- Problemas **free-entry**, el algoritmo tiene que encontrar el número más conveniente.
<!-- Cuidado que free-entry podría ser el competitivo en que llegan nuevas plantas en orden (greedy) -->

En el caso de varias facilities:
- Customer-choice: El cliente elije con cuál de las facilities interactúa.
- Allocation model: El que pone las facilities elige cuál suple a cuál cliente.

Kariv y Hakimi demostraron que el problema p-median general en un grafo es NP-Duro (1979b).
<!-- Más adelante hay una formulación matemática de este problema. -->

Problemas que pueden estar muy relacionados:
El Simple Plant Location Problem (SPLP) a.k.a. Uncapacitated Facility Location (UFL) problem.
Uncapacitated porque existen los capacitates en que hay un limite para la producción de una planta.

Körkel muestra la mejor metodología.

Maximum Covering Location Problem (MCLP): Colocar una cantidad fija de plantas y encontrar el máximo de clientes que se pueden alcanzar.
<!-- Es interesante que en las características del problema que yo trato, el "tamaño" (costo) de las plantas crece con la cantidad de clientes que deben atender. Ergo, aquí no sirve la estrategia de probar con varios p hasta encontrar el máx óptimo. -->

(Predominancia de soluciones de programación lineal)

Demanda puede cambiar en el futuro, hay modelos basados en **escenarios** y modelos **probabilísticos**.
<!-- Señalar que el modelo no considera la variación de la demanda en el tiempo -->

# Extras:

Planar location: Drezner et al. (2002)
<!-- Entender Elzinga-Hearn -->
