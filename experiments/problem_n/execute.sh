#!/bin/bash -e

rm -rf results || true
mkdir -p results

for nn in {20..10000..20}; do
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
            len=$(python3 -c "print(int((1000000.0*$nn/$density)**.5))")
            for tt in {1..50}; do (
                # Create random test case
                ttt=$(printf "%04d" $tt)
                filename="$foldname/problem-$ttt"
                python3 ../../tools/problem_generator.py deesu \
                    $nn $nn $len 1000 $alpha 1 \
                    "$filename.txt" "$filename-pos.txt"
                rm "$filename-pos.txt"
                python3 ../../tools/lp_problem_translator.py \
                    "$filename.txt" "$filename.lp"
                # Solve it with lp_solve
                { time -p lp_solve "$filename.lp" > "$filename-lp-res.txt"; } \
                    2> "$filename-lp-time.txt"
                # Solve it with greedy
                ../../geoloc.exe 1 1 1 "$filename.txt" "$filename-gd-res.txt"
            ) &
            done
            wait
            # Create files to store results of linear programming optimal sol.
            grep -R "user" "$foldname/"problem-*-lp-time.txt | \
                awk '{print $NF}' > "$foldname/lp-times.txt"
            grep -R "objective function:" "$foldname/"problem-*-lp-res.txt | \
                awk '{print $NF}' | cut -d'.' -f1 > "$foldname/lp-res.txt"
            for d in "$foldname/"problem-*-lp-res.txt; do cat "$d" | \
                grep "X" | grep " 1" | wc -l ; done > "$foldname/lp-nfacs.txt"
            # Create files to store results of greedy sol.
            grep -R "Value:" "$foldname/"problem-*-gd-res.txt | \
                awk '{print $NF}' > "$foldname/gd-res.txt"
            grep -R "Facilities:" "$foldname/"problem-*-gd-res.txt | \
                awk '{print $NF}' > "$foldname/gd-nfacs.txt"
            # Delete token
            rm "$foldname-was-runing"
        done
    done
done
