#!/bin/bash -e
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=26gb

# VARS:
# EXP STRA

# Tunning for the HPC cluster:
if [ -n "${PBS_O_WORKDIR+1}" ]; then
    cd "$PBS_O_WORKDIR"
    export lp_solve="$HOME/lp_solve_5.5/lp_solve/bin/ux64/lp_solve"
else
    export lp_solve="lp_solve"
fi

../geoloc.exe 400 800 20 ./out_prob_geo ./geo_res
