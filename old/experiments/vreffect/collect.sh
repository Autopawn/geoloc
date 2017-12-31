#!/bin/bash -e

rm -rf collect || true
mkdir -p collect

# NOTE: Remember to change this in generate.sh too
pptests=0.15
cctests=0.50

parameters='($P='"$pptests"', C='"$cctests"'$)'
colors='-colors={"gl":(1,0,0),"lp":(0,0,0)}'

lp_regex="s/solutions\/([0-9]+)\/lp_\w+.txt:([0-9\.]+) (\w+)/lp c \1 k \2 \3/"
fullVR_regex="s/solutions\/([0-9]+)\/fullVR_([0-9]+)_\w+.txt:([0-9\.]+) (\w+)/fullVR c \1 \2 \3 \4/"
gl_regex="s/solutions\/([0-9]+)\/gl_([0-9]+)_([0-9]+)_\w+.txt:([0-9\.]+) (\w+)/gl \3 \1 \2 \4 \5/"

# Collect the times
echo "" > collect/times.txt
grep -R . solutions/*/lp_times.txt | sed -E "$lp_regex" >> collect/times.txt
grep -R . solutions/*/fullVR_*_times.txt | sed -E "$fullVR_regex" >> collect/times.txt
grep -R . solutions/*/gl_*_times.txt | sed -E "$gl_regex" >> collect/times.txt
python ../../tools/plot_matrix.py -ly -sx -sy collect/times.txt collect/times.png \
    'Execution times v/s $VR$ '"$parameters" '$N$' '$PZ$'

# Collect the values
echo "" > collect/vals.txt
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> collect/vals.txt
grep -R . solutions/*/fullVR_*_vals.txt | sed -E "$fullVR_regex" >> collect/vals.txt
grep -R . solutions/*/gl_*_vals.txt | sed -E "$gl_regex" >> collect/vals.txt
python ../../tools/plot_matrix.py -sx collect/vals.txt collect/vals.png \
    'Solution value v/s $VR$ '"$parameters" '$N$' '$PZ$'

# Collect the number of factories
echo "" > collect/nfacs.txt
grep -R . solutions/*/lp_nfacs.txt | sed -E "$lp_regex" >> collect/nfacs.txt
grep -R . solutions/*/fullVR_*_nfacs.txt | sed -E "$fullVR_regex" >> collect/nfacs.txt
grep -R . solutions/*/gl_*_nfacs.txt | sed -E "$gl_regex" >> collect/nfacs.txt
python ../../tools/plot_matrix.py -sx -sy collect/nfacs.txt collect/nfacs.png \
    'No. of facilities v/s $VR$ '"$parameters" '$N$' '$PZ$'

# Create file for the proportions
python ../../tools/portion_of_max.py lp collect/vals.txt collect/props.txt
python ../../tools/plot_matrix.py -sx -sy collect/props.txt collect/props.png \
    'Ratio to optimal solution v/s $VR$ '"$parameters" '$N$' '$PZ$'
python ../../tools/plot_matrix.py -sx -sy -np collect/props.txt collect/props_np.png \
    'Ratio to optimal solution v/s $VR$ '"$parameters" '$N$' '$PZ$'

# Create file for difference with the fullVR:
python ../../tools/portion_of_max.py -i lp collect/vals.txt collect/props_wo_lp.txt
python ../../tools/portion_of_max.py -d fullVR collect/props_wo_lp.txt collect/props_diff_fullVR.txt
python ../../tools/plot_matrix.py -sx -sy -np collect/props_diff_fullVR.txt collect/props_np_diff_fullVR.png "$colors" \
    'Difference with fullVR in ratio to optimal solution v/s $VR$ '"$parameters" '$N$' '$PZ$'
