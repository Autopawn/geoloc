bash generate.sh 04many

qsub -N 04many_lp solve_lp.sh 04many lp
qsub -N 04many_greedy solve_geoloc.sh greedy 1 1
qsub -N 04many_geoloc400 solve_geoloc.sh geoloc400 400 #defaultvr
qsub -N 04many_geoloc800 solve_geoloc.sh geoloc800 800 #defaultvr
qsub -N 04many_geoloc2400vr1 solve_geoloc.sh geoloc2400vr1 2400 1
qsub -N 04many_random2400 solve_geoloc.sh random2400 2400 -1
