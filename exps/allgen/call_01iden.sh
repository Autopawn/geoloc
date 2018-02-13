source "./vars_01iden.sh"

bash generate.sh 01iden

qsub -N 01iden_lp -v 1=01iden,2=lp "solve_lp.sh"
qsub -N 01iden_greedy "solve_geoloc.sh" greedy 1 1
