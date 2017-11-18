#!/bin/bash -e

rm -rf problems || true
rm -rf solutions || true

mkdir problems

nntests="0050 0100 0150 0200 0250 0300 0350 0400 0450 0500 0550 0600 0650 0700 0750 0800 0850 0900 0950 1000 1050 1100 1150 1200 1250 1300 1350 1400 1450 1500 1550 1600 1650 1700 1750 1800 1850 1900 1950 2000"
pptests="0.05 0.10 0.15 0.20"
cctests="0.20 0.40 0.60 0.80 1.00"
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
