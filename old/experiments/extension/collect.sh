#!/bin/bash -e

rm -rf collect || true
mkdir -p collect

colors='-colors={"greedy":(1,0,0),"lp":(0,0,0)}'

lp_regex="s/solutions\/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/lp_\w+.txt:([0-9\.]+) (\w+)/lp \1 \2 \3 \4 \5/"
strategy_regex="s/solutions\/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/(([0-9]|-|\w)+)_\w+.txt:([0-9\.]+) (\w+)/\4 \1 \2 \3 \6 \7/"

# Collect the times
echo "" > collect/times.txt
grep -R . solutions/*/lp_times.txt | sed -E "$lp_regex" >> collect/times.txt
grep -R . solutions/*/stra_*_times.txt | sed -E "$strategy_regex" >> collect/times.txt
python ../../tools/plot_matrix.py -hx -ly -sx -sy collect/times.txt collect/times.png \
    "$colors" 'Execution times v/s $N$' '$P$' '$Co$'

# Collect the values
echo "" > collect/vals.txt
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> collect/vals.txt
grep -R . solutions/*/stra_*_vals.txt | sed -E "$strategy_regex" >> collect/vals.txt
python ../../tools/plot_matrix.py -hx -sx -sy collect/vals.txt collect/vals.png \
    "$colors" 'Solution value v/s $N$' '$P$' '$Co$'

# Collect the number of factories
echo "" > collect/nfacs.txt
grep -R . solutions/*/lp_nfacs.txt | sed -E "$lp_regex" >> collect/nfacs.txt
grep -R . solutions/*/stra_*_nfacs.txt | sed -E "$strategy_regex" >> collect/nfacs.txt
python ../../tools/plot_matrix.py -hx -sx -sy collect/nfacs.txt collect/nfacs.png \
    "$colors" 'No. of facilities v/s $N$' '$P$' '$Co$'

# Create file for the proportions
python ../../tools/portion_of_max.py lp collect/vals.txt collect/props.txt
python ../../tools/plot_matrix.py -np -hx -sx -sy collect/props.txt collect/props.png \
    "$colors" 'Ratio to optimal solution v/s $N$' '$P$' '$Co$'
