#!/bin/bash -xe

NFACS=50
MCLIE=100
MSIZE=1000

FCOST=500
VGAIN=250
TCOST=1

POOLSIZE=200

# Create random test case
python3 ../../tools/problem_generator.py deesu $NFACS $MCLIE $MSIZE $FCOST $VGAIN $TCOST problem.txt problem_pos.txt

# Find optimal solution with lp_solve
python3 ../../tools/lp_problem_translator.py problem.txt problem.lp
{ time lp_solve problem.lp > lp_result.txt; } 2> lp_time.txt

# Create a results folder to store the results
rm -rf results || true
mkdir -p results
# Compute with many poolsizes and full vision range
for PSIZE in {1..$POOLSIZE}; do
    FNAME=$(printf '%04d' "$PSIZE")
    ../../geoloc.exe $PSIZE $PSIZE 1 problem.txt "results/mge_$FNAME.txt"
    ../../geoloc_hd.exe $PSIZE $PSIZE 1 problem.txt "results/hd_$FNAME.txt"
done

# Write summary of the results
REGEXV='s/^results\/\(\w\+\)_\([0-9]\+\).*:[^[0-9]]*\([0-9]\+\).*/\1 \2 \3/'
grep -R "Value:" results | sort | sed -e "$REGEXV" > summary_values.txt
REGEXT='s/^results\/\(\w\+\)_\([0-9]\+\).*:#.*\([0-9]\+\.[0-9]\+\).*/\1 \2 \3/'
grep -R "Time:" results | sort | sed -e "$REGEXT" > summary_times.txt

# Create graph
python3 ../../tools/graph_from_summary.py 'Best solution value v/s $POOL\_SIZE$ \n $|Z|='$NFACS',|C|='$MCLIE',\gamma='$FCOST',\alpha='$VGAIN',\beta='$TCOST'$. Full vision range.' summary_values.txt value_graph.png
