#!/bin/bash -e
#PBS -o result.out -e result.err
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01

# Tunning for the HPC cluster:
if [ -n "${PBS_O_WORKDIR+1}" ]; then
    cd "$PBS_O_WORKDIR"
    export lp_solve="$HOME/lp_solve_5.5/lp_solve/bin/ux64/lp_solve"
else
    export lp_solve="lp_solve"
fi

rm -rf problems || true
rm -rf solutions || true

mkdir problems

nntests="50 150 250"
pptests="0.05 0.10 0.15 0.20"
cctests="0.30 0.50 0.70 0.90"

# Generate problems:
for nn in $nntests; do
    for pp in $pptests; do
        for cc in $cctests; do
            fname="problems/$nn"_"$pp"_"$cc"_prob
            #
            ll="10000"
            beta="1"
            alpha=$(python -c "print(int(round((3.0*$ll**2.0*$beta**2.0*$pp/3.14159265359)**0.5)))")
            gamma=$(python -c "print(int(round(3.14159265359*$nn*$alpha**3.0/(3.0*$ll**2.0*$beta**2.0))))")
            python ../../tools/prob_generator.py $nn $nn $ll $gamma $alpha $beta $fname
        done
    done
done

# Solve problems:
mkdir solutions
cd problems; for prob in * ; do
    python ../../../tools/prob_translator.py "$prob" lpsolve ../solutions/"$prob".lp
    lp_solve ../solutions/"$prob".lp > ../solutions/"$prob"
    python ../../../tools/svg_generator.py "$prob" -p ../solutions/"$prob" ../solutions/"$prob".svg
    rm ../solutions/"$prob".lp
    rm ../solutions/"$prob"
done
