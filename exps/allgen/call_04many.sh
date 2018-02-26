source "./vars_04many.sh"

bash generate.sh 04many

rm -rf sols_04many || true
mkdir sols_04many

#outdir="out/04many/$(date +%Y%m%d_%H%M%S)"
outdir="out_04many"
mkdir -p "$outdir"


qsub -N 04many_lp -o "$outdir"/lp.out -e "$outdir"/lp.err \
    -v EXP="04many",STRA="lp" solve_lp.sh

qsub -N 04many_greedy -o "$outdir"/greedy.out -e "$outdir"/greedy.err \
    -v EXP="04many",STRA="greedy",PZ="1",VR="1" solve_geoloc.sh

qsub -N 04many_geoloc400 -o "$outdir"/geoloc400.out -e "$outdir"/geoloc400.err \
    -v EXP="04many",STRA="geoloc400",PZ="400",VR="" solve_geoloc.sh

qsub -N 04many_geoloc800 -o "$outdir"/geoloc800.out -e "$outdir"/geoloc800.err \
    -v EXP="04many",STRA="geoloc800",PZ="800",VR="" solve_geoloc.sh

qsub -N 04many_geoloc2400vr1 \
    -o "$outdir"/geoloc2400vr1.out -e "$outdir"/geoloc2400vr1.err \
    -v EXP="04many",STRA="geoloc2400vr1",PZ="2400",VR="1" solve_geoloc.sh

qsub -N 04many_random2400 \
    -o "$outdir"/random2400.out -e "$outdir"/random2400.err \
    -v EXP="04many",STRA="random2400",PZ="2400",VR="-1" solve_geoloc.sh
