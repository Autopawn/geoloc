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

rm -rf solutions || true
mkdir solutions

# Solve problems:

cd problems; for foldr in * ; do
    mkdir -p ../solutions/"$foldr"
    touch ../solutions/"$foldr"/nfacs.txt
    touch ../solutions/"$foldr"/vals.txt
    for file in "$foldr"/* ; do (
        # Get the optimal solution:
        python ../../../tools/prob_translator.py "$file" lpsolve ../solutions/"$file".lp
        $lp_solve ../solutions/"$file".lp > ../solutions/"$file"
        rm ../solutions/"$file".lp
        # Create an SVG image
        if [ "$file" == "$foldr"/prob_1 ]; then
            python ../../../tools/svg_generator.py "$file" -p \
                ../solutions/"$file" ../solutions/"$foldr"/prob_1.svg
        fi
        # Get number of facilities
        cat ../solutions/"$file" | grep "X" | grep " 1" | wc -l \
            >> ../solutions/"$foldr"/nfacs.txt
        # Get value of objective function
        cat ../solutions/"$file" | grep "objective function:" | \
            awk '{print $NF}' | cut -d'.' -f1 >> ../solutions/"$foldr"/vals.txt
        # Delete solution to save space on the HPC cluster:
        if [ -n "${PBS_O_WORKDIR+1}" ]; then
            rm ../solutions/"$file"
        fi
    ) &
    done
    wait
done
