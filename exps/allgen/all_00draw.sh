source "./vars_00draw.sh"

bash generate.sh 00draw

EXP="00draw"

rm -rf sols_00draw || true
mkdir sols_00draw
rm -rf coll_00draw || true
mkdir coll_00draw


cd prob_00draw
for nn in $nntests; do
    for pp in $pptests; do
        for cc in $cctests; do
            foldr="$nn"_"$pp"_"$cc"
            mkdir -p ../sols_00draw/"$foldr"
            for tt in $(seq 1 $ntiers); do
                for kk in $(seq 1 $ncases); do
                    file="$foldr"/"$tt"_"$kk"
                    # Translate the problem to its geoloc and lp version:
                    python ../../../tools/prob_translator.py "$file" geoloc \
                        ../sols_00draw/"$file"_prob_geo
                    python ../../../tools/prob_translator.py "$file" lpsolve \
                        ../sols_00draw/"$file"_prob_lp
                    # Solve, get greedy solution
                    ../../../geoloc.exe 1 1 1 \
                        ../sols_00draw/"$file"_prob_geo \
                        ../sols_00draw/"$file"_sol_geo
                    # Solve, get lp solution
                    lp_solve ../sols_00draw/"$file"_prob_lp > \
                        ../sols_00draw/"$file"_sol_lp
                    # Generate svg draws
                    svgname="$foldr"_"$tt"_"$kk"
                    python ../../../tools/svg_generator.py "$file" \
                        -p ../sols_00draw/"$file"_sol_lp \
                        ../coll_00draw/"$svgname"_lp.svg
                    python ../../../tools/svg_generator.py "$file" \
                        -g ../sols_00draw/"$file"_sol_geo \
                        ../coll_00draw/"$svgname"_geo.svg
                done
            done
        done
    done
done
