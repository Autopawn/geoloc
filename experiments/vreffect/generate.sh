#!/bin/bash -e

rm -rf problems || true
rm -rf solutions || true

mkdir problems

nntests="050 100 150 200"

# NOTE: Remember to change this in solve.sh too
ncases=20
ntiers=10

# NOTE: Remember to change this in collect.sh too
pptests=0.15
cctests=0.50

# Generate problems:
for nn in $nntests; do
    for pp in $pptests; do
        for cc in $cctests; do
            fname="problems/$nn"
            mkdir "$fname"
            #
            ll="10000"
            beta="1"
            alpha=$(python -c "print(int(round((3.0*$ll**2.0*$beta**2.0*$pp/3.14159265359)**0.5)))")
            gamma=$(python -c "print(int(round($cc*$alpha*int(\"$nn\")*$pp)))")
            for tt in $(seq 1 $tiers); do
                for kk in $(seq 1 $ncases); do
                    pname="$fname"/prob_"$tt"_"$kk"
                    python ../../tools/prob_generator.py $nn $nn $ll $gamma $alpha $beta $pname
                done
            done
        done
    done
done
