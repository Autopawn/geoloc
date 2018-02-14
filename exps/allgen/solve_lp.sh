#!/bin/bash -e
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=30gb

# VARS:
# EXP STRA

# Tunning for the HPC cluster:
if [ -n "${PBS_O_WORKDIR+1}" ]; then
    cd "$PBS_O_WORKDIR"
    export lp_solve="$HOME/lp_solve_5.5/lp_solve/bin/ux64/lp_solve"
else
    export lp_solve="lp_solve"
fi

source ./vars_"$EXP".sh

strat="$STRA"

ulimit -Sv "$memlimit"

: > sols_"$EXP"/"$strat"_completed
cd prob_"$EXP"; for foldr in * ; do
    mkdir -p ../sols_"$EXP"/"$foldr"
    touch ../sols_"$EXP"/"$foldr"/"$strat"_nfacs
    touch ../sols_"$EXP"/"$foldr"/"$strat"_vals
    touch ../sols_"$EXP"/"$foldr"/"$strat"_times

    for tt in $(seq 1 $ntiers); do
        for kk in $(seq 1 $ncases); do (
            file="$foldr"/"$tt"_"$kk"
            bfile=$(basename "$file")
            # Translate the problem to its lpsolve version:
            python ../../../tools/prob_translator.py "$file" lpsolve \
                ../sols_"$EXP"/"$file"_"$strat"_prob
            # Solve and save the time on another file
            { time -p $lp_solve ../sols_"$EXP"/"$file"_"$strat"_prob > ../sols_"$EXP"/"$file"_"$strat"_sol; } \
                2> ../sols_"$EXP"/"$file"_"$strat"_time
            # Remove the translation because it won't be needed longer
            rm ../sols_"$EXP"/"$file"_"$strat"_prob
            # Get number of facilities
            cat ../sols_"$EXP"/"$file"_"$strat"_sol | grep "X" | grep " 1" | \
                wc -l | sed -e "s/$/ $bfile/" \
                >> ../sols_"$EXP"/"$foldr"/"$strat"_nfacs
            # Get value of objective function
            cat ../sols_"$EXP"/"$file"_"$strat"_sol | \
                grep "objective function:" | awk '{print $NF}' | \
                cut -d'.' -f1 | sed -e "s/$/ $bfile/" \
                >> ../sols_"$EXP"/"$foldr"/"$strat"_vals
            # Get time
            cat ../sols_"$EXP"/"$file"_"$strat"_sol | grep "user" | \
                awk '{print $NF}' | sed -e "s/$/ $bfile/" \
                >> ../sols_"$EXP"/"$foldr"/"$strat"_times
            # Delete solution:
            rm ../sols_"$EXP"/"$file"_"$strat"_sol
            rm ../sols_"$EXP"/"$file"_"$strat"_time
        )&
        done
        wait
    done
    echo "$foldr" >> ../sols_"$EXP"/"$strat"_completed
done
