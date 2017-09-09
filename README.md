# Geoloc

## C code

The main version of the algorithm is done in the C language. To compile and create `geoloc.exe`:

    ```bash
    $ make geoloc
    ```

To create a test problem with `100` facilities and clients (of weight 1) on the same, randomly distributed, positions over a rectangle of size `1000`, with a facility fixed cost of `800`, a variant gain of `300`, and transport cost per weight unit of `1`:

    ```bash
    $ python3 tools/problem_generator.py seesu 100 1000 800 300 1 cases/test_case.txt cases/test_case.pos
    ```

This will create the file `cases/test_case.txt` with the problem definition and `cases/test_case.pos` with the positions of the facilities and clients (used later for the creation of images).

To run the program over the test case, with a pool of `1000` and a vision range of `100`, saving the `10` best solutions to the `results/test_result.txt` file:

    ```bash
    $ mkdir -p results
    $ ./geoloc.exe 1000 100 10 cases/test_case.txt results/test_result.txt
    ```

To create an `svg` image of the best solution:

    ```bash
    python3 tools/svg_generator.py cases/test_case.pos results/test_result.txt test_solution.svg
    ```

`test_solution.svg` is the resulting image.

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

## Document compilation

* `texlive-babel-spanish`.
