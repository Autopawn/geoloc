#!/bin/bash -e

source ./many_vars.sh

lp_regex="s/solutions\/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/lp_\w+.txt:([0-9\.]+) (\w+)/lp \1 \2 \3 \4 \5/"
strategy_regex="s/solutions\/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/stra_(([0-9]|-|\w)+)_\w+.txt:([0-9\.]+) (\w+)/\4 \1 \2 \3 \6 \7/"

target="collect/$(date +%Y%m%d_%H%M%S)"
mkdir -p $target
cat many_vars.sh > $target/vars.txt

echo "TARGET: $target"

# Collect the times
grep -R . solutions/*/lp_times.txt | sed -E "$lp_regex" >> "$target"/times.txt
grep -R . solutions/*/stra_*_times.txt | sed -E "$strategy_regex" >> "$target"/times.txt
python ../../tools/plot_matrix.py -hx -ly -sx -sy "$target"/times.txt "$target"/times.png \
    "$colors" 'Tiempos v/s $N$' '$P$' '$Co$'

# Collect the values
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> "$target"/vals.txt
grep -R . solutions/*/stra_*_vals.txt | sed -E "$strategy_regex" >> "$target"/vals.txt
python ../../tools/plot_matrix.py -hx -sx -sy "$target"/vals.txt "$target"/vals.png \
    "$colors" 'Valor de la sol. v/s $N$' '$P$' '$Co$'

# Collect the number of factories
grep -R . solutions/*/lp_nfacs.txt | sed -E "$lp_regex" >> "$target"/nfacs.txt
grep -R . solutions/*/stra_*_nfacs.txt | sed -E "$strategy_regex" >> "$target"/nfacs.txt
python ../../tools/plot_matrix.py -hx -sx -sy "$target"/nfacs.txt "$target"/nfacs.png \
    "$colors" 'No. de instalaciones v/s $N$' '$P$' '$Co$'

# Create file for the proportions
python ../../tools/portion_of_max.py lp "$target"/vals.txt "$target"/props.txt
python ../../tools/plot_matrix.py -np -hx -sx -sy "$target"/props.txt "$target"/props.png \
    "$colors" 'Optimalidad v/s $N$' '$P$' '$Co$'
