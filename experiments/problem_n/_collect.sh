# BEING MANTAINED!!!!

#!/bin/bash -e

mkdir -p collect

folder="results"

# Collect the lp times
grep -R . $folder/*/lp-times.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/time \1 \2 \3 \5/" > collect/times.txt

# Collect the values
echo "" > collect/res.txt
grep -R . $folder/*/lp-res.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/optimal \1 \2 \3 \5/" >> collect/res.txt
grep -R . $folder/*/gd-res.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/greedy \1 \2 \3 \5/" >> collect/res.txt

# Collect the number of facilities
echo "" > collect/nfacs.txt
grep -R . $folder/*/lp-nfacs.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/optimal \1 \2 \3 \5/" >> collect/nfacs.txt
grep -R . $folder/*/gd-nfacs.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/greedy \1 \2 \3 \5/" >> collect/nfacs.txt
