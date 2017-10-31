#!/bin/bash -e

touch nfacs.txt
touch vals.txt
cd solutions; for foldr in * ; do
    python ../../../tools/mean_and_std.py "$foldr"/nfacs.txt >> ../nfacs.txt
    python ../../../tools/mean_and_std.py "$foldr"/vals.txt >> ../vals.txt
done
