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

rm result.err result.out || true
rm -rf results || true
mkdir -p results

# v deesu o dtesu
problemk=dtesu

# v created with np.array(np.round(np.logspace(1,3,15,base=10)),dtype='int32')
nntests="10 14 19 27 37 52 72 100 139 193 268 373 518 720 1000"

for nn in $nntests; do
    for density in 50 100 150; do
        for alpha in 200 400 600; do
            nnn=$(printf "%05d" $nn)
            ddd=$(printf "%05d" $density)
            aaa=$(printf "%05d" $alpha)
            foldname="results/$nnn-$ddd-$aaa"
            # Create folder
            mkdir -p "$foldname"
            # Create token to see what folder was running when halted
            touch "$foldname-was-runing"
            len=$(python -c "print(int((1000000.0*$nn/$density)**.5))")
            for tt in {1..20}; do (
                # Create random test case
                ttt=$(printf "%04d" $tt)
                filename="$foldname/problem-$ttt"
                python ../../tools/problem_generator.py $problemk \
                    $nn $nn $len 1000 $alpha 1 \
                    "$filename.txt" "$filename-pos.txt"
                python ../../tools/lp_problem_translator.py \
                    "$filename.txt" "$filename.lp"
                # Solve it with lp_solve
                { time -p $lp_solve "$filename.lp" > "$filename-lp-res.txt"; } \
                    2> "$filename-lp-time.txt"
                # Solve it with greedy
                ../../geoloc.exe 1 1 1 "$filename.txt" "$filename-gd-res.txt"
            ) &
            done
            wait
            # Create files to store results of linear programming optimal sol.
            grep -R "user" $foldname/problem-*-lp-time.txt | \
                awk '{print $NF}' > "$foldname/lp-times.txt"
            grep -R "objective function:" $foldname/problem-*-lp-res.txt | \
                awk '{print $NF}' | cut -d'.' -f1 > "$foldname/lp-res.txt"
            for d in "$foldname/"problem-*-lp-res.txt; do cat "$d" | \
                grep "X" | grep " 1" | wc -l ; done > "$foldname/lp-nfacs.txt"
            # Create files to store results of greedy sol.
            grep -R "Value:" $foldname/problem-*-gd-res.txt | \
                awk '{print $NF}' > "$foldname/gd-res.txt"
            grep -R "Facilities:" $foldname/problem-*-gd-res.txt | \
                awk '{print $NF}' > "$foldname/gd-nfacs.txt"
            # Delete token
            rm "$foldname-was-runing"
            # Delete the no longer useful files:
            rm $foldname/problem-*
        done
    done
done
