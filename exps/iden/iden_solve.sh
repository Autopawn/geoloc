#!/bin/bash -e
#PBS -N iden
#PBS -o result.out -e result.err
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=30gb

# Tunning for the HPC cluster:
if [ -n "${PBS_O_WORKDIR+1}" ]; then
    cd "$PBS_O_WORKDIR"
    rm result.err result.out || true
    export lp_solve="$HOME/lp_solve_5.5/lp_solve/bin/ux64/lp_solve"
else
    export lp_solve="lp_solve"
fi

rm -rf solutions || true
mkdir solutions

# Solve problems:

cd problems; for foldr in * ; do
    mkdir -p ../solutions/"$foldr"
    touch ../solutions/"$foldr"/lp_nfacs.txt
    touch ../solutions/"$foldr"/lp_vals.txt
    touch ../solutions/"$foldr"/lp_times.txt
    for file in "$foldr"/* ; do (
        bfname=$(basename "$file")
        #### Get the optimal solution:
        python ../../../tools/prob_translator.py "$file" lpsolve ../solutions/"$file".lp
        { time -p $lp_solve ../solutions/"$file".lp > ../solutions/"$file"_lp_sol; } \
            2> ../solutions/"$file"_lp_times
        rm ../solutions/"$file".lp
        # Get number of facilities
        cat ../solutions/"$file"_lp_sol | grep "X" | grep " 1" | wc -l | \
            sed -e "s/$/ $bfname/" \
            >> ../solutions/"$foldr"/lp_nfacs.txt
        # Get value of objective function
        cat ../solutions/"$file"_lp_sol | grep "objective function:" | \
            awk '{print $NF}' | cut -d'.' -f1 | sed -e "s/$/ $bfname/" \
            >> ../solutions/"$foldr"/lp_vals.txt
        # Get time
        cat ../solutions/"$file"_lp_times | grep "user" | \
            awk '{print $NF}' | sed -e "s/$/ $bfname/" \
            >> ../solutions/"$foldr"/lp_times.txt
        # Delete solution:
        rm ../solutions/"$file"_lp_sol
        rm ../solutions/"$file"_lp_times
        #
        #### Get the greedy solution:
        python ../../../tools/prob_translator.py "$file" geoloc ../solutions/"$file".gl
        ../../../geoloc.exe 1 1 1 ../solutions/"$file".gl \
            ../solutions/"$file"_greedy_sol
        rm ../solutions/"$file".gl
        # Get number of facilities
        cat ../solutions/"$file"_greedy_sol | grep "Facilities:" | \
            awk '{print $NF}' | sed -e "s/$/ $bfname/" \
            >> ../solutions/"$foldr"/greedy_nfacs.txt
        # Get value of objective function
        cat ../solutions/"$file"_greedy_sol | grep "Value:" | \
            awk '{print $NF}' | sed -e "s/$/ $bfname/" \
            >> ../solutions/"$foldr"/greedy_vals.txt
        # Get time
        cat ../solutions/"$file"_greedy_sol | grep "Time:" | \
            awk '{print $NF}' | sed -e "s/$/ $bfname/" \
            >> ../solutions/"$foldr"/greedy_times.txt
        # Delete solution:
        rm ../solutions/"$file"_greedy_sol
    ) &
    done
    wait
done
