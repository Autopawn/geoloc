#!/bin/bash -e

rm -rf collect || true
mkdir -p collect

# NOTE: Remember to change this in generate.sh too
pptests=0.15
cctests=0.50

parameters='($P='"$pptests"', C='"$cctests"'$)'
colors='-colors={"gl":(1,0,0),"lp":(0,0,0)}'

lp_regex="s/solutions\/([0-9]+)\/lp_\w+.txt:([0-9\.]+) (\w+)/lp c \1 \2 \3/"
gl_regex="s/solutions\/([0-9]+)\/gl_([0-9]+)_\w+.txt:([0-9\.]+) (\w+)/gl \2 \1 \3 \4/"

# Collect the times
echo "" > collect/times.txt
grep -R . solutions/*/lp_times.txt | sed -E "$lp_regex" >> collect/times.txt
grep -R . solutions/*/gl_*_times.txt | sed -E "$gl_regex" >> collect/times.txt
python ../../tools/plot_matrix.py "$colors" -ly -sx -sy collect/times.txt collect/times.png \
    'Execution times v/s $PZ$ with full $VR$ '"$parameters" '$N$'

# Collect the values
echo "" > collect/vals.txt
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> collect/vals.txt
grep -R . solutions/*/gl_*_vals.txt | sed -E "$gl_regex" >> collect/vals.txt
python ../../tools/plot_matrix.py "$colors" -sx collect/vals.txt collect/vals.png \
    'Solution value v/s $PZ$ with full $VR$ '"$parameters" '$N$'

# Collect the number of factories
echo "" > collect/nfacs.txt
grep -R . solutions/*/lp_nfacs.txt | sed -E "$lp_regex" >> collect/nfacs.txt
grep -R . solutions/*/gl_*_nfacs.txt | sed -E "$gl_regex" >> collect/nfacs.txt
python ../../tools/plot_matrix.py "$colors" -sx -sy collect/nfacs.txt collect/nfacs.png \
    'No. of facilities v/s $PZ$ with full $VR$ '"$parameters" '$N$'

# Create file for the proportions
python ../../tools/portion_of_max.py lp collect/vals.txt collect/props.txt
python ../../tools/plot_matrix.py "$colors" -sx -sy collect/props.txt collect/props.png \
    'Ratio to optimal solution v/s $PZ$ with full $VR$ '"$parameters" '$N$'

# Create file for the negated proportions
python ../../tools/portion_of_max.py -i -n lp collect/vals.txt collect/nprops.txt
python ../../tools/plot_matrix.py "$colors" -r -sx -sy -ly -lx collect/nprops.txt collect/nprops.png \
    'Loss w.r.t. optimal v/s $PZ$ with full $VR$ '"$parameters" '$N$'
