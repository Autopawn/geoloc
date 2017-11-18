#!/bin/bash -e

#!/bin/bash -e

rm -rf collect || true
mkdir -p collect

touch nfacs.txt
touch vals.txt
cd solutions; for foldr in * ; do
    python ../../../tools/mean_and_std.py "$foldr"/nfacs.txt >> ../collect/nfacs.txt
    python ../../../tools/mean_and_std.py "$foldr"/vals.txt >> ../collect/vals.txt
done
