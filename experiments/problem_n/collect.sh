# BEING MANTAINED!!!!

#!/bin/bash -e

rm -rf collect || true
mkdir -p collect

# Collect the times
echo "" > collect/times.txt
grep -R . solutions/*/lp_times.txt | sed -E "s/\w+\/([0-9]+)_([0-9\.]+)_([0-9\.]+)\/(\w|-|\.)+:([0-9\.]+)/lp \1 \2 \3 \5/" >> collect/times.txt
grep -R . solutions/*/gl_*_times.txt | sed -E "s/\w+\/([0-9]+)_([0-9\.]+)_([0-9\.]+)\/(\w|-|\.)+_(\w+)_times\.txt:([0-9\.]+)/gl_\5 \1 \2 \3 \6/" >> collect/times.txt
python ../../tools/plot_matrix.py -lx -ly collect/times.txt collect/times.png

# Collect the values
echo "" > collect/vals.txt
grep -R . solutions/*/lp_vals.txt | sed -E "s/\w+\/([0-9]+)_([0-9\.]+)_([0-9\.]+)\/(\w|-|\.)+:([0-9\.]+)/lp \1 \2 \3 \5/" >> collect/vals.txt
grep -R . solutions/*/gl_*_vals.txt | sed -E "s/\w+\/([0-9]+)_([0-9\.]+)_([0-9\.]+)\/(\w|-|\.)+_(\w+)_vals\.txt:([0-9\.]+)/gl_\5 \1 \2 \3 \6/" >> collect/vals.txt
python ../../tools/plot_matrix.py -lx collect/vals.txt collect/vals.png

# Collect the number of factories
echo "" > collect/nfacs.txt
grep -R . solutions/*/lp_nfacs.txt | sed -E "s/\w+\/([0-9]+)_([0-9\.]+)_([0-9\.]+)\/(\w|-|\.)+:([0-9\.]+)/lp \1 \2 \3 \5/" >> collect/nfacs.txt
grep -R . solutions/*/gl_*_nfacs.txt | sed -E "s/\w+\/([0-9]+)_([0-9\.]+)_([0-9\.]+)\/(\w|-|\.)+_(\w+)_nfacs\.txt:([0-9\.]+)/gl_\5 \1 \2 \3 \6/" >> collect/nfacs.txt
python ../../tools/plot_matrix.py -lx collect/nfacs.txt collect/nfacs.png
