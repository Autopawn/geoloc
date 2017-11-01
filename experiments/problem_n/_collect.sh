# BEING MANTAINED!!!!

#!/bin/bash -e

rm -rf collect || true
mkdir -p collect

# Collect the times
echo "" > collect/times.txt
grep -R . solutions/*/lp_times.txt | sed -E "s/\w+\/([0-9]+)_([0-9\.]+)_([0-9\.]+)\/(\w|-|\.)+:([0-9\.]+)/lp \1 \2 \3 \5/" >> collect/times.txt
grep -R . solutions/*/gl_*_times.txt | sed -E "s/\w+\/([0-9]+)_([0-9\.]+)_([0-9\.]+)\/(\w|-|\.)+_(\w+)_times\.txt:([0-9\.]+)/gl_\5 \1 \2 \3 \6/" >> collect/times.txt


# # Collect the values
# echo "" > collect/res.txt
# grep -R . $folder/*/lp-res.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/optimal \1 \2 \3 \5/" >> collect/res.txt
# grep -R . $folder/*/gd-res.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/greedy \1 \2 \3 \5/" >> collect/res.txt
#
# # Collect the number of facilities
# echo "" > collect/nfacs.txt
# grep -R . $folder/*/lp-nfacs.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/optimal \1 \2 \3 \5/" >> collect/nfacs.txt
# grep -R . $folder/*/gd-nfacs.txt | sed -E "s/$folder\/([0-9]+)-([0-9]+)-([0-9]+)\/(\w|-|\.)+:([0-9]+)/greedy \1 \2 \3 \5/" >> collect/nfacs.txt
