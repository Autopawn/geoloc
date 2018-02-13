#!/bin/bash -e
#PBS -o result.out -e result.err
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=30gb

# USAGE:
# solve_geoloc.sh <experiment> <strategy_name> <pool_size> <vision_range>

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
pz="$3"
vr="$4"

ulimit -Sv "$memlimit"

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
            nn=$(cat "$file" | grep "c " | wc -l)
            # Translate the problem to its geoloc version:
            python ../../../tools/prob_translator.py "$file" geoloc \
                ../sols_"$1"/"$file"_"$strat"_prob
            if [ -z "$vr" ]; then
                # Default vision range = 2*max(pz,nn)
                maxn=$(python -c "print(max("$pz","$nn"))")
                gvr=$((2*maxn))
            else
                gvr="$vr"
            fi
            # Solve, get only the best solution
            ../../../geoloc.exe "$pz" "$gvr" 1 \
                ../sols_"$1"/"$file"_"$strat"_prob \
                ../sols_"$1"/"$file"_"$strat"_sol
            # Remove the translation because it won't be needed longer
            rm ../sols_"$1"/"$file"_"$strat"_prob
            # Get number of facilities
            cat ../sols_"$1"/"$file"_"$strat"_sol | grep "Facilities:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                >> ../sols_"$1"/"$foldr"/"$strat"_nfacs
            # Get value of objective function
            cat ../sols_"$1"/"$file"_"$strat"_sol | grep "Value:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                >> ../sols_"$1"/"$foldr"/"$strat"_vals
            # Get time
            cat ../sols_"$1"/"$file"_"$strat"_sol | grep "Time:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                >> ../sols_"$1"/"$foldr"/"$strat"_times
            # Delete solution:
            rm ../sols_"$1"/"$file"_"$strat"_sol
        )&
        done
        wait
    done
    echo "$foldr" >> ../sols_"$1"/"$strat"_completed
done
