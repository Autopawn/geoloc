# Parameters for experimental design

After some experimentation, we discovered that the problems where the optimal number of **selected** facilities is very high are not of interest since the greedy solution is, relatively speaking, only a little worse than the optimal one.

Thus, the idea is to change the parameters on a way that the expected number of facilities remains controlled and small, the chosen parameters for each experiment have to determinate the $\alpha$ and $\gamma$. The $beta$ and $L$ (the side of the square where the possible facility locations and clients appear) can be set as constants.


Being $N$ the number of clients (and possible facility locations):

### Portion of the total gain

If we assume that the distribution of the total gain is uniform, each differential of area adds $\alpha N/L^2$ gain, however, due to transport costs, if that differential is at a distance $r$ of the nearest facility, it adds:

\[
\frac{\alpha N}{L^2} \left( 1-\frac{r}{r_{crit}} \right) = \frac{\alpha N}{L^2} \left( 1-\frac{r \beta}{\alpha} \right)
\]

Integrating over the area of the circle of radius $r_{crit}$ can be seen like the obtaining the volume of a cone of height $\alpha N/L^2$. This results on the expected gain for a free facility:

\[
\frac{1}{3} \frac{\alpha N}{L^2} r_{crit}^2 \pi = \frac{\pi}{3} \frac{N}{L^2} \frac{\alpha^3}{\beta^2}
\]

As the total gain is $\alpha N$, the portion of the total gain that a facility is expected to catch is:

\[
P = \frac{\pi}{3L^2} \frac{\alpha^2}{\beta^2}
\]

### Expected relative cost

The expected relative cost is the relation between the cost of a facility and its expected gain:

\[
C = \frac{\gamma}{\alpha N P}
\]

Another parameter, that ends determining the $\gamma$, is the relation between the cost of a facility and the

## Final Parameters

This experiments are run for:

| Parameter | Values |
| :-------- | :----- |
| $N$       | $\{50,150,250\}$ |
| $P$       | $\{0.10,0.20,0.30,0.40\}$ |
| $C$       | $\{0.55,0.70,0.85,1.00\}$ |

The parameters are calculated as:

| Parameter | Formula |
| :-------- | :---: |
| $L$         | $10000$ |
| $N$         | $N$     |
| $\beta$     | $1$ |
| $\alpha$    | $\sqrt{\frac{3L^2 \beta^2 P}{\pi}}$ |
| $\gamma$    | $\frac{\pi N}{3L^2} \frac{\alpha^3}{\beta^2}$ |

# Conclusions

The number of facilities doesn't change too much for different values of $C$ except when they are near $0$ or near $1$, in the first case, the number of facilities increases significatively, on the second one decreases randomly in some cases because the utility of one facility is small and removing one client may mean that it is no longer profitable.

<!-- Confirm more this last one assertion ^ -->

As $P$ gets larger the number of optimal facilities decreases, a value of $0.05$ results in about 5 facilities for a *normal* value of $C$.
