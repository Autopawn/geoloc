#!/bin/bash -e
#NOTE: put PBS -N name
#PBS -o result.out -e result.err
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=30gb

# USAGE:
# solve_lp.sh <experiment> <strategy_name>

# Tunning for the HPC cluster:
if [ -n "${PBS_O_WORKDIR+1}" ]; then
    cd "$PBS_O_WORKDIR"
    rm result.err result.out || true
    export lp_solve="$HOME/lp_solve_5.5/lp_solve/bin/ux64/lp_solve"
else
    export lp_solve="lp_solve"
fi

source ./vars_"$1".sh
rm -rf sols_"$1" || true
mkdir sols_"$1"

strat="$2"

cd prob_"$1"; for foldr in * ; do
    mkdir -p ../sols_"$1"/"$foldr"
    : > ../sols_"$1"/"$strat"_completed
    touch ../sols_"$1"/"$foldr"/"$strat"_nfacs
    touch ../sols_"$1"/"$foldr"/"$strat"_vals
    touch ../sols_"$1"/"$foldr"/"$strat"_times

    for tt in $(seq 1 $ntiers); do
        for kk in $(seq 1 $ncases); do (
            file="$foldr"/prob_"$tt"_"$kk"
            bfile=$(basename "$file")
            # Translate the problem to its lpsolve version:
            python ../../../tools/prob_translator.py "$file" lpsolve \
                ../sols_"$1"/"$file"_"$strat"_prob
            # Solve and save the time on another file
            { time -p $lp_solve ../sols_"$1"/"$file"_"$strat"_prob > ../sols_"$1"/"$file"_"$strat"_sol; } \
                2> ../sols_"$1"/"$file"_"$strat"_time
            # Remove the translation because it won't be needed longer
            rm ../sols_"$1"/"$file"_"$strat"_prob
            # Get number of facilities
            cat ../sols_"$1"/"$file"_"$strat"_sol | grep "X" | grep " 1" | \
                wc -l | sed -e "s/$/ $bfile/" \
                >> ../sols_"$1"/"$foldr"/"$strat"_nfacs
            # Get value of objective function
            cat ../sols_"$1"/"$file"_"$strat"_sol | \
                grep "objective function:" | awk '{print $NF}' | \
                cut -d'.' -f1 | sed -e "s/$/ $bfile/" \
                >> ../sols_"$1"/"$foldr"/"$strat"_vals
            # Get time
            cat ../sols_"$1"/"$file"_"$strat"_sol | grep "user" | \
                awk '{print $NF}' | sed -e "s/$/ $bfile/" \
                >> ../sols_"$1"/"$foldr"/"$strat"_times
            # Delete solution:
            rm ../sols_"$1"/"$file"_"$strat"_sol
            rm ../sols_"$1"/"$file"_"$strat"_time
        )&
        done
        wait
    done
    echo "$foldr" >> ../sols_"$1"/"$strat"_completed
done
