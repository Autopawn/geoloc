#!/bin/bash -e
#PBS -N vrfx
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

source ./vrfx_vars.sh

rm -rf solutions || true
mkdir solutions

cd problems; for foldr in * ; do
    mkdir -p ../solutions/"$foldr"
    touch ../solutions/"$foldr"/lp_nfacs.txt
    touch ../solutions/"$foldr"/lp_vals.txt
    touch ../solutions/"$foldr"/lp_times.txt
    for pz in $poolsizes ; do
        for vr in $vranges ; do
            touch ../solutions/"$foldr"/gl_"$pz"_"$vr"_nfacs.txt
            touch ../solutions/"$foldr"/gl_"$pz"_"$vr"_vals.txt
            touch ../solutions/"$foldr"/gl_"$pz"_"$vr"_times.txt
        done
    done
    #
    for tt in $(seq 1 $ntiers); do
        for file in "$foldr"/prob_"$tt"_* ; do (
            bfname=$(basename "$file")
            nn=$(cat "$file" | grep "c " | wc -l)
            #### Get the optimal solution:
            python ../../../tools/prob_translator.py "$file" lpsolve ../solutions/"$file".lp
            { time -p $lp_solve ../solutions/"$file".lp > ../solutions/"$file"_lp_sol; }\
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

            #### Get the geoloc solutions
            python ../../../tools/prob_translator.py "$file" geoloc ../solutions/"$file".gl
            for pz in $poolsizes ; do
                #### Get the solution with full VR
                # Solve using geoloc
                fullvr=$(python -c "print(int(\"$pz\")*$nn)")
                ../../../geoloc.exe "$pz" "$fullvr" 1 ../solutions/"$file".gl \
                    ../solutions/"$file"_fullVR_"$pz"_sol
                # Get number of facilities
                cat ../solutions/"$file"_fullVR_"$pz"_sol | grep "Facilities:" | \
                    awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                    >> ../solutions/"$foldr"/fullVR_"$pz"_nfacs.txt
                # Get value of objective function
                cat ../solutions/"$file"_fullVR_"$pz"_sol | grep "Value:" | \
                    awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                    >> ../solutions/"$foldr"/fullVR_"$pz"_vals.txt
                # Get time
                cat ../solutions/"$file"_fullVR_"$pz"_sol | grep "Time:" | \
                    awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                    >> ../solutions/"$foldr"/fullVR_"$pz"_times.txt
                # Delete solution
                rm ../solutions/"$file"_fullVR_"$pz"_sol

                for vr in $vranges ; do
                    # Solve using geoloc
                    ../../../geoloc.exe "$pz" "$vr" 1 ../solutions/"$file".gl \
                        ../solutions/"$file"_gl_"$pz"_"$vr"_sol
                    # Get number of facilities
                    cat ../solutions/"$file"_gl_"$pz"_"$vr"_sol | grep "Facilities:" | \
                        awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                        >> ../solutions/"$foldr"/gl_"$pz"_"$vr"_nfacs.txt
                    # Get value of objective function
                    cat ../solutions/"$file"_gl_"$pz"_"$vr"_sol | grep "Value:" | \
                        awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                        >> ../solutions/"$foldr"/gl_"$pz"_"$vr"_vals.txt
                    # Get time
                    cat ../solutions/"$file"_gl_"$pz"_"$vr"_sol | grep "Time:" | \
                        awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                        >> ../solutions/"$foldr"/gl_"$pz"_"$vr"_times.txt
                    # Delete solution
                    rm ../solutions/"$file"_gl_"$pz"_"$vr"_sol
                done
            done
            rm ../solutions/"$file".gl
        ) &
        done
        wait
    done
done
