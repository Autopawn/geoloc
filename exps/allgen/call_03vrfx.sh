bash generate.sh 03vrfx

qsub -N 03vrfx_lp solve_lp.sh 02vrfx lp

fullvr=$((150*150))

qsub -N 03vrfx_lp solve_itervr.sh 03vrfx geoloc050 050
qsub -N 03vrfx_lp solve_itervr.sh 03vrfx geoloc100 100
qsub -N 0#vrfx_lp solve_itervr.sh 03vrfx geoloc150 150
qsub -N 03vrfx_lp solve_geoloc.sh 03vrfx fullVR050 050 "$fullvr"
qsub -N 03vrfx_lp solve_geoloc.sh 03vrfx fullVR100 100 "$fullvr"
qsub -N 0#vrfx_lp solve_geoloc.sh 03vrfx fullVR150 150 "$fullvr"

poolsizes="050 100 150"
