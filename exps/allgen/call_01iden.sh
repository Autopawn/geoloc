source "./vars_01iden.sh"

bash generate.sh 01iden

qsub -N 01iden_lp solve_lp.sh 01iden lp
qsub -N 01iden_greedy solve_geoloc.sh greedy 1 1
