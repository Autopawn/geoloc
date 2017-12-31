#!/bin/bash -e
#PBS -N extension
#PBS -o result.out -e result.err
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01

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

stran=8
stranames="greedy gl-n1o2-1 gl-n1o2-n gl-n1o2-n3o2 gl-n-1 gl-n-n1o2 gl-n-n3o4 gl-n-n"
strapzexps="0 0.5 0.5 0.5 1.0 1.0 1.0 1.0"
stravrexps="0 0 1.0 1.5 0 0.5 0.75 1.0"

# Solve problems:

cd problems; for foldr in * ; do
    mkdir -p ../solutions/"$foldr"
    touch ../solutions/"$foldr"/lp_nfacs.txt
    touch ../solutions/"$foldr"/lp_vals.txt
    touch ../solutions/"$foldr"/lp_times.txt
    for file in "$foldr"/* ; do (
        bfname=$(basename "$file")
        nn=$(cat "$file" | grep "c " | wc -l)
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

        # GEOLOC SOLUTIONS:
        python ../../../tools/prob_translator.py "$file" geoloc ../solutions/"$file".gl

        for ((ii=1; ii <= stran ; ii++)) ; do
            pzexp=$(echo "$strapzexps" | cut -d " " -f "$ii")
            vrexp=$(echo "$stravrexps" | cut -d " " -f "$ii")
            straname=$(echo "$stranames" | cut -d " " -f "$ii")
            pz=$(python -c "print(int(int(\"$nn\")**$pzexp))")
            vr=$(python -c "print(int(int(\"$nn\")**$vrexp))")
            #
            ../../../geoloc.exe "$pz" "$vr" 1 ../solutions/"$file".gl \
                ../solutions/"$file"_"$straname"_sol
            # Get number of facilities
            cat ../solutions/"$file"_"$straname"_sol | grep "Facilities:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
            >> ../solutions/"$foldr"/stra_"$straname"_nfacs.txt
            # Get value of objective function
            cat ../solutions/"$file"_"$straname"_sol | grep "Value:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                >> ../solutions/"$foldr"/stra_"$straname"_vals.txt
            # Get time
            cat ../solutions/"$file"_"$straname"_sol | grep "Time:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                >> ../solutions/"$foldr"/stra_"$straname"_times.txt
            # Delete solution:
            rm ../solutions/"$file"_"$straname"_sol
        done
        #
        rm ../solutions/"$file".gl
    )&
    done
    wait
done
