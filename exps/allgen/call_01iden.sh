source "./vars_01iden.sh"

bash generate.sh 01iden

rm -rf sols_01iden || true
mkdir sols_01iden

#outdir="out/01iden/$(date +%Y%m%d_%H%M%S)"
outdir="out_01iden"
mkdir -p "$outdir"

qsub -N 01iden_lp -o "$outdir"/lp.out -e "$outdir"/lp.err \
    -v EXP="01iden",STRA="lp" solve_lp.sh
qsub -N 01iden_greedy -o "$outdir"/greedy.out -e "$outdir"/greedy.err \
    -v EXP="01iden",STRA="greedy",PZ="1",VR="1" solve_geoloc.sh
