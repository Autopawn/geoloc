#!/bin/bash -e

source ./vrfx_vars.sh

target="collect/$(date +%Y%m%d_%H%M%S)"
mkdir -p $target
cat vrfx_vars.sh > $target/vars.txt

echo "TARGET: $target"

lp_regex="s/solutions\/([0-9]+)\/lp_\w+.txt:([0-9\.]+) (\w+)/lp c \1 k \2 \3/"
fullVR_regex="s/solutions\/([0-9]+)\/fullVR_([0-9]+)_\w+.txt:([0-9\.]+) (\w+)/fullVR c \1 \2 \3 \4/"
gl_regex="s/solutions\/([0-9]+)\/gl_([0-9]+)_([0-9]+)_\w+.txt:([0-9\.]+) (\w+)/gl \3 \1 \2 \4 \5/"

# Collect the times
grep -R . solutions/*/lp_times.txt | sed -E "$lp_regex" >> \
    "$target"/times.txt
grep -R . solutions/*/fullVR_*_times.txt | sed -E "$fullVR_regex" >> \
    "$target"/times.txt
grep -R . solutions/*/gl_*_times.txt | sed -E "$gl_regex" >> \
    "$target"/times.txt
python ../../tools/plot_matrix.py -w -w -sx -sy "$target"/times.txt \
    "$target"/times.png 'Tiempos promedio ejecutando v/s $VR$' '$N$' '$PZ$'

# Collect the values
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> \
    "$target"/vals.txt
grep -R . solutions/*/fullVR_*_vals.txt | sed -E "$fullVR_regex" >> \
    "$target"/vals.txt
grep -R . solutions/*/gl_*_vals.txt | sed -E "$gl_regex" >> \
    "$target"/vals.txt
python ../../tools/plot_matrix.py -w -w -sx "$target"/vals.txt \
    "$target"/vals.png 'Valor promedio de las soluciones v/s $VR$' '$N$' '$PZ$'

# Create file for the proportions
python ../../tools/portion_of_max.py lp "$target"/vals.txt \
    "$target"/props.txt
python ../../tools/plot_matrix.py -w -w -sx -sy -np "$target"/props.txt \
    "$target"/props_np.png 'Optimalidad promedio v/s $VR$' '$N$' '$PZ$'

# Create file for difference with the fullVR:
python ../../tools/portion_of_max.py -i lp "$target"/vals.txt \
    "$target"/props_wo_lp.txt
python ../../tools/portion_of_max.py -d fullVR \
    "$target"/props_wo_lp.txt "$target"/props_diff_fullVR.txt
python ../../tools/plot_matrix.py -w -w -sx -sy -np "$target"/props_diff_fullVR.txt \
    "$target"/props_np_diff_fullVR.png "$colors" \
    'Diferencia de valor relativo con full-$VR$ v/s $VR$' '$N$' '$PZ$'
