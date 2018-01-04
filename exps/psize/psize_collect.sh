#!/bin/bash -e

source ./psize_vars.sh

target="collect/$(date +%Y%m%d_%H%M%S)"
mkdir -p $target
cat psize_vars.sh > $target/vars.txt

echo "TARGET: $target"

parameters='($P='"$pptests"', C='"$cctests"'$)'
colors='-colors={"gl":(1,0,0),"lp":(0,0,0)}'

lp_regex="s/solutions\/([0-9]+)\/lp_\w+.txt:([0-9\.]+) (\w+)/lp c \1 \2 \3/"
gl_regex="s/solutions\/([0-9]+)\/gl_([0-9]+)_\w+.txt:([0-9\.]+) (\w+)/gl \2 \1 \3 \4/"

# Collect the times
grep -R . solutions/*/lp_times.txt | sed -E "$lp_regex" >> \
    $target/times.txt
grep -R . solutions/*/gl_*_times.txt | sed -E "$gl_regex" >> \
    $target/times.txt
python ../../tools/plot_matrix.py "$colors" -ly -sx -sy $target/times.txt \
    $target/times.png \
    'Tiempos de ejecución v/s $PZ$ con full-$VR$ '"$parameters" '$N$'

# Collect the values
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> \
    $target/vals.txt
grep -R . solutions/*/gl_*_vals.txt | sed -E "$gl_regex" >> \
    $target/vals.txt
python ../../tools/plot_matrix.py "$colors" -sx $target/vals.txt \
    $target/vals.png \
    'Valor de la solución v/s $PZ$ con full-$VR$ '"$parameters" '$N$'

# Collect the number of factories
grep -R . solutions/*/lp_nfacs.txt | sed -E "$lp_regex" >> \
    $target/nfacs.txt
grep -R . solutions/*/gl_*_nfacs.txt | sed -E "$gl_regex" >> \
    $target/nfacs.txt
python ../../tools/plot_matrix.py "$colors" -sx -sy $target/nfacs.txt \
    $target/nfacs.png \
    'No. de instalaciones v/s $PZ$ con full-$VR$ '"$parameters" '$N$'

# Create file for the proportions
python ../../tools/portion_of_max.py lp $target/vals.txt $target/props.txt
python ../../tools/plot_matrix.py "$colors" -sx -sy $target/props.txt \
    $target/props.png \
    'Radio a la solución óptima v/s $PZ$ con full-$VR$ '"$parameters" '$N$'

# Create file for the negated proportions
python ../../tools/portion_of_max.py -i -n lp $target/vals.txt \
    $target/nprops.txt
python ../../tools/plot_matrix.py "$colors" -r -sx -sy -ly -lx \
    $target/nprops.txt $target/nprops.png \
    'Pérdida respecto al óptimo v/s $PZ$ con full-$VR$ '"$parameters" '$N$'
