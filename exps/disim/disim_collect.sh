#!/bin/bash -e

source ./disim_vars.sh

target="collect/$(date +%Y%m%d_%H%M%S)"
mkdir -p $target
cat disim_vars.sh > $target/vars.txt

echo "TARGET: $target"

disim_regex="s/solutions\/prob_([0-9\.]+)_gl_([0-9\.]+)_dst:#DIST ([0-9\.]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.]+)/prob_\1 \7 \2 \3 1 prob_\1/"
remain_regex="s/solutions\/prob_([0-9\.]+)_gl_([0-9\.]+)_rem:#REMAINED ([0-9]+) ([0-9]+) from ([0-9]+) to ([0-9]+) with vr ([0-9]+) radio ([0-9\.]+)/prob_\1 \7 \2 \3 \8 prob_\1/"

: > $target/all.txt
: > $target/remains_tot.txt

# Collect the dissimilitude pair distance on the linked list
for prob in $problems ; do
    nn=$(echo $prob | sed -E 's/prob_([0-9]+)/\1/')
    nnn=$(python -c "print(int(\"$nn\"))")

    grep -R . solutions/*_dst | sed -E "$disim_regex" | grep "$prob" >> \
        $target/disims_$nn.txt

    cat $target/disims_$nn.txt >> $target/all.txt

    python ../../tools/plot_matrix.py -sx -sy -hg $target/disims_$nn.txt \
        $target/disims_$nn.png 'Distancias en posiciones de pares de soluciones similares (Problema $N='$nnn'$)' '$PZ$' '$i$'

    grep -R . solutions/*_rem | sed -E "$remain_regex" | grep "$prob" >> \
        $target/remains_tot.txt
done

# Dischard unwanted iterations:
: > $target/all_filered.txt
cat $target/all.txt | grep ' 2 1 prob' >> $target/all_filered.txt
cat $target/all.txt | grep ' 3 1 prob' >> $target/all_filered.txt
cat $target/all.txt | grep ' 4 1 prob' >> $target/all_filered.txt
cat $target/all.txt | grep ' 5 1 prob' >> $target/all_filered.txt

: > $target/remains_filtered.txt
cat $target/remains_tot.txt | grep -E ' 2 [0-9]+\.' >> $target/remains_filtered.txt
cat $target/remains_tot.txt | grep -E ' 3 [0-9]+\.' >> $target/remains_filtered.txt
cat $target/remains_tot.txt | grep -E ' 4 [0-9]+\.' >> $target/remains_filtered.txt
cat $target/remains_tot.txt | grep -E ' 5 [0-9]+\.' >> $target/remains_filtered.txt

python ../../tools/plot_matrix.py -sx -sy -hg $target/all_filered.txt \
    $target/disims_all.png "$colors" 'Frecuencias de distancias (en posiciones de la lista) de pares de soluciones similares' '$PZ$' '$i$'
python ../../tools/plot_matrix.py -sx -sy -np $target/remains_filtered.txt \
    $target/remains_all.png "$colors" 'Parte de soluciones iguales a obtenidas con Full-$VR$ v/s $VR$' '$PZ$' '$i$'
