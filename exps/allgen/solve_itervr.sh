#!/bin/bash -e
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=30gb

# VARS:
# EXP STRA PZ

source ./vars_"$EXP".sh

MYSTRA="$STRA"

for vr in "$vranges"; do
    export EXP
    export STRA="$MYSTRA"_"$vr"
    export PZ
    export VR="$vr"
    bash -e ./solve_geoloc
done
