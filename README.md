# Geoloc

## C code and Python tools

The main version of the algorithm is done in the C language. To compile and create `geoloc.exe`:

```bash
$ make geoloc
```

To create a random test problem with `100` clients and `50` facility locations on a rectangle of size `1000`, with a facility fixed cost of `800`, a variant gain of `300`, and transport cost per weight unit of `1`:

```bash
$ mkdir -p cases
$ python3 tools/prob_generator.py 100 50 1000 800 300 1 cases/test_prob.txt
```

This will create the file `cases/test_prob.txt` with a generic definition of the problem.

To create a definition of the problem that can be used as input for `geoloc`, you use te translator:

```bash
$ python3 tools/prob_translator.py cases/test_prob.txt geoloc cases/test_geoloc_prob.txt
```

To run the program over the test case, with a pool size of `100` and a vision range of `20`, saving the `10` best solutions to the `cases/test_res.txt` file:

```bash
$ ./geoloc.exe 100 20 10 cases/test_geoloc_prob.txt cases/test_res.txt
```

To create an `svg` image of the best solution:

```bash
$ python3 tools/svg_generator.py -g cases/test_res.txt cases/test_prob.txt cases/test_res.svg
```

`cases/test_res.svg` is the resulting image.

To create a linear programming problem for `lp_solve` from the test case:

```bash
$ python3 tools/prob_translator.py cases/test_prob.txt lpsolve cases/test_lp_prob.lp
```

### Problem file format

```
<facility_cost>
<variant_gain_per_weight>
<transport_cost_per_weight_per_distance>
<number_of_facilities(n)>
<number_of_clients(m)>

<distance_f1_f1> <distance_f1_f2> ... <distance_f1_fn>
<distance_f2_f1> <distance_f2_f2> ... <distance_f2_fn>
    :                :                    :
<distance_fn_f1> <distance_fn_f2> ... <distance_fn_fn>

<weight_c1> <weight_c2> ... <weight_cm>

<distance_f1_c1> <distance_f1_c2> ... <distance_f1_cm>
<distance_f2_c1> <distance_f2_c2> ... <distance_f2_cm>
    :                :                    :
<distance_fn_c1> <distance_fn_c2> ... <distance_fn_cm>
```

## Haskell code

The haskell code, on `hs_src` is a previous version of the algorithm, not as fast than the C one but highly more generalized. The generalized functions are placed on `Exploration.hs`, the particular case of facility location on two dimentional euclidian space is defined on `Geoloc.hs`.

* Install packages with `cabal` (package `cabal-install` in `dnf`):

```bash
$ cabal update
$ cabal install <package>
```

* Package `munkres` for the hungarian method, thanks to *Balazs Komuves*.

## Dependencies:

For the `loglogloglinreg.py` tool, the `python3-scikit-learn` package is required.
