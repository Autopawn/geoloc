source "./vars_03vrfx.sh"

bash generate.sh 03vrfx

rm -rf sols_03vrfx || true
mkdir sols_03vrfx

#outdir="out/03vrfx/$(date +%Y%m%d_%H%M%S)"
outdir="out_03vrfx"
mkdir -p "$outdir"


qsub -N 03vrfx_lp -o "$outdir"/lp.out -e "$outdir"/lp.err \
    -v EXP="03vrfx",STRA="lp" solve_lp.sh

for pz in $psizes; do
    qsub -N 03vrfx_geoloc"$pz" -o "$outdir"/geoloc"$pz".out \
        -e "$outdir"/geoloc"$pz".err \
        -v EXP="03vrfx",STRA="geoloc""$pz",PZ="$pz" solve_itervr.sh
    #
    qsub -N 03vrfx_fullVR"$pz" -o "$outdir"/fullVR"$pz".out \
        -e "$outdir"/fullVR"$pz".err \
        -v EXP="03vrfx",STRA="fullVR""$pz",PZ="$pz",VR="$enoughVR" solve_geoloc.sh
done
