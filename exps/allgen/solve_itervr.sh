#!/bin/bash -e
#PBS -o result.out -e result.err
#PBS -l cput=8000:00:01
#PBS -l walltime=8000:00:01
#PBS mem=30gb

# Usage:
# solve_itervr.sh <experiment> <strategy_name> <pool_size>

source ./vars_"$1".sh

for vr in "$vranges"; do
    bash -e ./solve_geoloc "$1" "$2"_"$vr" "$3" "$vr"
done
