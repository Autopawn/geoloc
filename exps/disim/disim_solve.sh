#!/bin/bash -e

#!/bin/bash -e
#PBS -N disim
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

source ./disim_vars.sh

rm -r solutions || true
mkdir solutions

rm -r problems || true
mkdir problems

cp -r ../tests/* problems

cd problems; for file in $problems ; do
    nn=$(cat "$file" | grep "c " | wc -l)
    #### Get the geoloc version of the problem
    python ../../../tools/prob_translator.py "$file" geoloc \
        ../solutions/"$file".gl
    for pz in $poolsizes ; do (
        # Solve using geoloc
        vrange=$(python -c "print(int(\"$pz\")*$nn)")
        ../../../geoloc_pairs.exe "$pz" "$vrange" 1 ../solutions/"$file".gl \
        ../solutions/"$file"_gl_"$pz"_sol | grep '#DIST' > \
        ../solutions/"$file"_gl_"$pz"_dst
    ) &
    done
    wait
    rm ../solutions/"$file".gl
done
