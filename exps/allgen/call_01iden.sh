#PBS -N 01iden
#PBS -o result.out -e result.err
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=30gb

bash generate.sh 01iden

# Set memory limit for this and all subprocesses
ulimit -Sv $((1024))

bash solve_lp.sh 01iden lp
