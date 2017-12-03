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

# Collect the values
echo "" > collect/vals.txt
grep -R . solutions/*/lp_vals.txt | sed -E "$lp_regex" >> collect/vals.txt
grep -R . solutions/*/gl_*_vals.txt | sed -E "$gl_regex" >> collect/vals.txt

# Create file for the negated proportions
python ../../tools/portion_of_max.py -i -n lp collect/vals.txt collect/nprops.txt
# Use the negated proportions to
python ../../tools/means.py collect/nprops.txt > collect/nprop_means.txt
