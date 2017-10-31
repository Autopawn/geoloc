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


poolsizes="1 4 16 64 256 1024"

# Solve problems:

cd problems; for foldr in * ; do
    mkdir -p ../solutions/"$foldr"
    touch ../solutions/"$foldr"/lp_nfacs.txt
    touch ../solutions/"$foldr"/lp_vals.txt
    touch ../solutions/"$foldr"/lp_times.txt
    for pz in poolsizes ; do
        touch ../solutions/"$foldr"/gd_$pz_nfacs.txt
        touch ../solutions/"$foldr"/gd_$pz_vals.txt
        touch ../solutions/"$foldr"/gd_$pz_times.txt
    done
    #
    for file in "$foldr"/* ; do (
        #### Get the optimal solution:
        python ../../../tools/prob_translator.py "$file" lpsolve ../solutions/"$file".lp
        { time -p $lp_solve ../solutions/"$file".lp > ../solutions/"$file"_lp_sol; }\
            2> ../solutions/"$file"_lp_times
        rm ../solutions/"$file".lp
        # Get number of facilities
        cat ../solutions/"$file"_lp_sol | grep "X" | grep " 1" | wc -l \
            >> ../solutions/"$foldr"/lp_nfacs.txt
        # Get value of objective function
        cat ../solutions/"$file"_lp_sol | grep "objective function:" | \
            awk '{print $NF}' | cut -d'.' -f1 >> ../solutions/"$foldr"/lp_vals.txt
        # Get time
        cat ../solutions/"$file"_lp_times | grep "user" | \
            awk '{print $NF}' > ../solutions/"$foldr"/lp_times.txt
        # Delete solution to save space on the HPC cluster:
        if [ -n "${PBS_O_WORKDIR+1}" ]; then
            rm ../solutions/"$file"_lp_sol
            rm ../solutions/"$file"_lp_times
        fi
        #### Get the geoloc solutions
        python ../../../tools/prob_translator.py "$file" geoloc ../solutions/"$file".gl
        for pz in poolsizes ; do
            if [ $pz -eq 1 ]; then
                vrange=1
            else
                vrange=10000000
            fi
            ../../../geoloc.exe "$pz" "$vrange" 1 ../solutions/"$file".gl \
                ../solutions/"$file"_gd_$pz_sol
            # Get number of facilities
            cat ../solutions/"$file"_gd_$pz_sol | grep "Facilities:" | \
                awk '{print $NF}' >> ../solutions/"$foldr"/gd_$pz_nfacs.txt
            # Get value of objective function
            cat ../solutions/"$file"_gd_$pz_sol | grep "Value:" | \
                awk '{print $NF}' >> ../solutions/"$foldr"/gd_$pz_vals.txt
            # Get time
            cat ../solutions/"$file"_gd_$pz_sol | grep "Time:" | \
                awk '{print $NF}' >> ../solutions/"$foldr"/gd_$pz_times.txt
            # Delete solution
            if [ -n "${PBS_O_WORKDIR+1}" ]; then
                rm ../solutions/"$file"_gd_$pz_sol
            fi
        done
        rm ../solutions/"$file".gl
    ) &
    done
    wait
done
