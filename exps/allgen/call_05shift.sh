source "./vars_05shift.sh"

bash generate.sh 05shift

rm -rf sols_05shift || true
mkdir sols_05shift

#outdir="out/05shift/$(date +%Y%m%d_%H%M%S)"
outdir="out_05shift"
rm -rf "$outdir" || true
mkdir -p "$outdir"


qsub -N 05shift_lp -o "$outdir"/lp.out -e "$outdir"/lp.err -v EXP="05shift",STRA="lp" solve_lp.sh

qsub -N 05shift_greedy -o "$outdir"/greedy.out -e "$outdir"/greedy.err -v EXP="05shift",STRA="greedy",PZ="1",VR="1" solve_geoloc.sh

qsub -N 05shift_geoloc800vr100 -o "$outdir"/geoloc800vr100.out -e "$outdir"/geoloc800vr100.err -v EXP="05shift",STRA="geoloc800vr100",PZ="800",VR="100" solve_geoloc.sh

qsub -N 05shift_geoloc400vr200 -o "$outdir"/geoloc400vr200.out -e "$outdir"/geoloc400vr200.err -v EXP="05shift",STRA="geoloc400vr200",PZ="400",VR="200" solve_geoloc.sh

qsub -N 05shift_geoloc200vr400 -o "$outdir"/geoloc200vr400.out -e "$outdir"/geoloc200vr400.err -v EXP="05shift",STRA="geoloc200vr400",PZ="200",VR="400" solve_geoloc.sh

qsub -N 05shift_geoloc100vr800 -o "$outdir"/geoloc100vr800.out -e "$outdir"/geoloc100vr800.err -v EXP="05shift",STRA="geoloc100vr800",PZ="100",VR="800" solve_geoloc.sh
