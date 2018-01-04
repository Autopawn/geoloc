#!/bin/bash -e

source ./disim_vars.sh

target="collect/$(date +%Y%m%d_%H%M%S)"
mkdir -p $target
cat disim_vars.sh > $target/vars.txt

echo "TARGET: $target"

disim_regex="s/solutions\/prob_([0-9\.]+)_gl_([0-9\.]+)_dst:#DIST ([0-9\.]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.]+)/prob_\1 \7 \2 \3 1 prob_\1/"
remain_regex="s/solutions\/prob_([0-9\.]+)_gl_([0-9\.]+)_rem:#REMAINED ([0-9]+) ([0-9]+) from ([0-9]+) to ([0-9]+) with vr ([0-9]+) radio ([0-9\.]+)/prob_\1 \7 \2 \3 \8 prob_\1/"

# Collect the dissimilitude pair distance on the linked list
for prob in $problems ; do
    nn=$(echo $prob | sed -E 's/prob_([0-9]+)/\1/')
    nnn=$(python -c "print(int(\"$nn\"))")

    grep -R . solutions/*_dst | sed -E "$disim_regex" | grep "$prob" >> \
        $target/disims_$nn.txt
    python ../../tools/plot_matrix.py -sx -sy -hg $target/disims_$nn.txt \
        $target/disims_$nn.png 'Distancias en posiciones de pares de soluciones similares (Problema $N='$nnn'$)' '$PZ$' '$i$'

    grep -R . solutions/*_rem | sed -E "$remain_regex" | grep "$prob" >> \
        $target/remains_tot.txt
done
python ../../tools/plot_matrix.py -sx -sy -np $target/remains_tot.txt \
    $target/remains_$nn.png "$colors" 'Parte de soluciones iguales a obtenidas con Full-$VR$ v/s $VR$' '$PZ$' '$i$'
