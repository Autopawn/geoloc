source "./vars_03vrfx.sh"

bash generate.sh 03vrfx

rm -rf sols_03vrfx || true
mkdir sols_03vrfx

outdir="out/03vrfx/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$outdir"


qsub -N 03vrfx_lp -o "$outdir"/lp.out -e "$outdir"/lp.err \
    -v EXP="03vrfx",STRA="lp" solve_lp.sh

# max(nn) max(pz)
fullvr=$((150*150))

qsub -N 03vrfx_geoloc050 -o "$outdir"/geoloc050.out -e "$outdir"/geoloc050.err \
    -v EXP="03vrfx",STRA="geoloc050",PZ="050" solve_itervr.sh
qsub -N 03vrfx_geoloc100 -o "$outdir"/geoloc100.out -e "$outdir"/geoloc100.err \
    -v EXP="03vrfx",STRA="geoloc100",PZ="100" solve_itervr.sh
qsub -N 03vrfx_geoloc150 -o "$outdir"/geoloc150.out -e "$outdir"/geoloc150.err \
    -v EXP="03vrfx",STRA="geoloc150",PZ="150" solve_itervr.sh

qsub -N 03vrfx_fullVR050 -o "$outdir"/fullVR050.out -e "$outdir"/fullVR050.err \
    -v EXP="03vrfx",STRA="fullVR050",PZ="050",VR="$fullvr"
qsub -N 03vrfx_fullVR100 -o "$outdir"/fullVR100.out -e "$outdir"/fullVR100.err \
    -v EXP="03vrfx",STRA="fullVR100",PZ="100",VR="$fullvr"
qsub -N 03vrfx_fullVR150 -o "$outdir"/fullVR150.out -e "$outdir"/fullVR150.err \
    -v EXP="03vrfx",STRA="fullVR150",PZ="150",VR="$fullvr"
