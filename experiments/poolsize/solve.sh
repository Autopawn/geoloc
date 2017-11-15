#!/bin/bash -e
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

poolsizes="010 020 030 040 050 060 070 080 090 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300 310 320 330 340 350 360 370 380 390 400 410 420 430 440 450 460 470 480 490 500"

cd problems; for foldr in * ; do
    mkdir -p ../solutions/"$foldr"
    touch ../solutions/"$foldr"/lp_nfacs.txt
    touch ../solutions/"$foldr"/lp_vals.txt
    touch ../solutions/"$foldr"/lp_times.txt
    for pz in $poolsizes ; do
        touch ../solutions/"$foldr"/gl_"$pz"_nfacs.txt
        touch ../solutions/"$foldr"/gl_"$pz"_vals.txt
        touch ../solutions/"$foldr"/gl_"$pz"_times.txt
    done
    #
    for file in "$foldr"/* ; do (
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
        # Delete solution to save space on the HPC cluster:
        if [ -n "${PBS_O_WORKDIR+1}" ]; then
            rm ../solutions/"$file"_lp_sol
            rm ../solutions/"$file"_lp_times
        fi
        #### Get the geoloc solutions
        python ../../../tools/prob_translator.py "$file" geoloc ../solutions/"$file".gl
        for pz in $poolsizes ; do
            # Calculate range
            vrange=$(python -c "print(int(\"$pz\")*$nn)")
            # Solve using geoloc
            ../../../geoloc.exe "$pz" "$vrange" 1 ../solutions/"$file".gl \
                ../solutions/"$file"_gl_"$pz"_sol
            # Get number of facilities
            cat ../solutions/"$file"_gl_"$pz"_sol | grep "Facilities:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                >> ../solutions/"$foldr"/gl_"$pz"_nfacs.txt
            # Get value of objective function
            cat ../solutions/"$file"_gl_"$pz"_sol | grep "Value:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                >> ../solutions/"$foldr"/gl_"$pz"_vals.txt
            # Get time
            cat ../solutions/"$file"_gl_"$pz"_sol | grep "Time:" | \
                awk '{print $NF}' | sed -e "s/$/ $bfname/" \
                >> ../solutions/"$foldr"/gl_"$pz"_times.txt
            # Delete solution
            rm ../solutions/"$file"_gl_"$pz"_sol
        done
        rm ../solutions/"$file".gl
    ) &
    done
    wait
done
