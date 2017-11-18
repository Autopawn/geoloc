#!/bin/bash -e

rm -rf problems || true
rm -rf solutions || true

mkdir problems

nntests="050 100 150 200"
pptests="0.05 0.10 0.15 0.20"
cctests="0.25 0.50 0.75 1.00"
ncases=40

# Generate problems:
for nn in $nntests; do
    for pp in $pptests; do
        for cc in $cctests; do
            fname="problems/$nn"_"$pp"_"$cc"
            mkdir "$fname"
            #
            ll="10000"
            beta="1"
            alpha=$(python -c "print(int(round((3.0*$ll**2.0*$beta**2.0*$pp/3.14159265359)**0.5)))")
            gamma=$(python -c "print(int(round($cc*$alpha*$nn*$pp)))")
            for kk in $(seq 1 $ncases); do
                pname="$fname"/prob_"$kk"
                python ../../tools/prob_generator.py $nn $nn $ll $gamma $alpha $beta $pname
            done
        done
    done
done
