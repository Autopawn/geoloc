#!/bin/bash -e
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=30gb

# VARS:
# EXP STRA PZ

# Tunning for the HPC cluster:
if [ -n "${PBS_O_WORKDIR+1}" ]; then
    cd "$PBS_O_WORKDIR"
    export lp_solve="$HOME/lp_solve_5.5/lp_solve/bin/ux64/lp_solve"
else
    export lp_solve="lp_solve"
fi

source ./vars_"$EXP".sh

MYSTRA="$STRA"

for vr in $vranges; do
    export EXP
    export STRA="$MYSTRA"_"$vr"
    export PZ
    export VR="$vr"
    bash -e ./solve_geoloc.sh
done
