source "./vars_04many.sh"

bash generate.sh 04many

rm -rf sols_04many || true
mkdir sols_04many

#outdir="out/04many/$(date +%Y%m%d_%H%M%S)"
outdir="out_04many"
rm -rf "$outdir" || true
mkdir -p "$outdir"


qsub -N 04many_lp -o "$outdir"/lp.out -e "$outdir"/lp.err \
    -v EXP="04many",STRA="lp" solve_lp.sh

qsub -N 04many_greedy -o "$outdir"/greedy.out -e "$outdir"/greedy.err \
    -v EXP="04many",STRA="greedy",PZ="1",VR="1" solve_geoloc.sh

qsub -N 04many_geoloc300 -o "$outdir"/geoloc300.out -e "$outdir"/geoloc300.err \
    -v EXP="04many",STRA="geoloc300",PZ="300",VR="" solve_geoloc.sh

qsub -N 04many_geoloc600 -o "$outdir"/geoloc600.out -e "$outdir"/geoloc600.err \
    -v EXP="04many",STRA="geoloc600",PZ="600",VR="" solve_geoloc.sh

qsub -N 04many_geoloc3000vr1 \
    -o "$outdir"/geoloc3000vr1.out -e "$outdir"/geoloc3000vr1.err \
    -v EXP="04many",STRA="geoloc3000vr1",PZ="3000",VR="1" solve_geoloc.sh

qsub -N 04many_random3000 \
    -o "$outdir"/random3000.out -e "$outdir"/random3000.err \
    -v EXP="04many",STRA="random3000",PZ="3000",VR="-1" solve_geoloc.sh
