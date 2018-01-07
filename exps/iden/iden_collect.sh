#!/bin/bash -e

source ./iden_vars.sh

target="collect/$(date +%Y%m%d_%H%M%S)"
mkdir -p $target
cat iden_vars.sh > $target/vars.txt

echo "TARGET: $target"

lp_regex="s/solutions\/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/lp_\w+.txt:([0-9\.]+) (\w+)/lp \1 \2 \3 \4 \5/"
greedy_regex="s/solutions\/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/greedy_\w+.txt:([0-9\.]+) (\w+)/greedy \1 \2 \3 \4 \5/"

# Collect the times
grep -R . solutions/*/lp_times.txt | sed -E "$lp_regex" >> \
    $target/times.txt
python ../../tools/plot_matrix.py -hx -ly -sx -sy $target/times.txt \
    $target/times.png 'Tiempos v/s $N$' '$P$' '$Co$'
python ../../tools/plot_matrix.py -hx -lx -ly -sx -sy $target/times.txt \
    $target/lx_times.png 'Tiempos v/s $N$' '$P$' '$Co$'

# Collect the values
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> \
    $target/vals.txt
grep -R . solutions/*/greedy_vals.txt | sed -E "$greedy_regex" >> \
    $target/vals.txt
python ../../tools/plot_matrix.py -hx -sx -sy $target/vals.txt \
    $target/vals.png 'Valor de la sol. v/s $N$' '$P$' '$Co$'

# Collect the number of factories
grep -R . solutions/*/lp_nfacs.txt | sed -E "$lp_regex" >> \
    $target/nfacs.txt
grep -R . solutions/*/greedy_nfacs.txt | sed -E "$greedy_regex" >> \
    $target/nfacs.txt
python ../../tools/plot_matrix.py -hx -sx -sy $target/nfacs.txt \
    $target/nfacs.png 'No. de instalaciones v/s $N$' '$P$' '$Co$'

# Create file for the proportions
python ../../tools/portion_of_max.py -i lp $target/vals.txt \
    $target/props.txt
python ../../tools/plot_matrix.py -hx -sx -sy $target/props.txt \
    $target/props.png 'Optimalidad v/s $N$' '$P$' '$Co$'
