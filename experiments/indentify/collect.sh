#!/bin/bash -e

rm -rf collect || true
mkdir -p collect

lp_regex="s/solutions\/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/lp_\w+.txt:([0-9\.]+) (\w+)/lp \1 \2 \3 \4 \5/"
greedy_regex="s/solutions\/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/greedy_\w+.txt:([0-9\.]+) (\w+)/greedy \1 \2 \3 \4 \5/"

# Collect the times
echo "" > collect/times.txt
grep -R . solutions/*/lp_times.txt | sed -E "$lp_regex" >> collect/times.txt
# grep -R . solutions/*/greedy_times.txt | sed -E "$greedy_regex" >> collect/times.txt
python ../../tools/plot_matrix.py -ly -sx -sy collect/times.txt collect/times.png \
    'Execution times v/s $N$' '$P$' '$C$'

# Collect the values
echo "" > collect/vals.txt
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> collect/vals.txt
grep -R . solutions/*/greedy_vals.txt | sed -E "$greedy_regex" >> collect/vals.txt
python ../../tools/plot_matrix.py -sx collect/vals.txt collect/vals.png \
    'Solution value v/s $N$' '$P$' '$C$'

# Collect the number of factories
echo "" > collect/nfacs.txt
grep -R . solutions/*/lp_nfacs.txt | sed -E "$lp_regex" >> collect/nfacs.txt
grep -R . solutions/*/greedy_nfacs.txt | sed -E "$greedy_regex" >> collect/nfacs.txt
python ../../tools/plot_matrix.py -sx -sy collect/nfacs.txt collect/nfacs.png \
    'No. of facilities v/s $N$' '$P$' '$C$'

# Create file for the proportions
python ../../tools/portion_of_max.py lp collect/vals.txt collect/props.txt
python ../../tools/plot_matrix.py -sx -sy collect/props.txt collect/props.png \
    'Ratio to optimal solution v/s $N' '$P$' '$C$'
