#!/bin/bash -xe

# Create random test case
python3 ../../tools/problem_generator.py deesu 50 100 1000 500 250 1 problem.txt problem_pos.txt

# Find optimal solution with lp_solve
python3 ../../tools/lp_problem_translator.py problem.txt problem.lp
{ time lp_solve problem.lp > lp_result.txt; } 2> lp_time.txt

# Create a results folder to store the results
rm -rf results || true
mkdir -p results
# Compute with many poolsizes and full vision range
for PSIZE in {1..200}; do
    FNAME=$(printf '%04d' "$PSIZE")
    ../../geoloc.exe $PSIZE $PSIZE 1 problem.txt "results/mge_$FNAME.txt"
    ../../geoloc_hd.exe $PSIZE $PSIZE 1 problem.txt "results/hd_$FNAME.txt"
done

# Write summary of the results
REGEXV='s/^results\/\(\w\+\)_\([0-9]\+\).*:[^[0-9]]*\([0-9]\+\).*/\1 \2 \3/'
grep -R "Value:" results | sort | sed -e "$REGEXV" > summary_values.txt
REGEXT='s/^results\/\(\w\+\)_\([0-9]\+\).*:#.*\([0-9]\+\.[0-9]\+\).*/\1 \2 \3/'
grep -R "Time:" results | sort | sed -e "$REGEXT" > summary_times.txt
