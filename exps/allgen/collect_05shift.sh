#!/bin/bash -e

source ./vars_05shift.sh


# target="collect/$(date +%Y%m%d_%H%M%S)"
target="coll_05shift"

stra_regex="s/([0-9\.]+)_([0-9\.]+)_([0-9\.]+)\/(\w+)_(\w+):([0-9\.]+) (\w+)/\4 \1 \2 \3 \6 \7/"

rm -rf "$target" || true
mkdir -p "$target"
cat ./vars_05shift.sh > "$target"/vars.txt

echo "TARGET: $target"

# Collect the times
cd sols_05shift
for compfile in $(ls *_completed); do
    stra=$(echo "$compfile" | cut -d _ -f 1)
    for foldr in $(cat "$compfile"); do
        echo "$foldr"
        grep -H . "$foldr"/*"$stra"_nfacs | sed -E "$stra_regex" >> \
            ../"$target"/nfacs
        grep -H . "$foldr"/*"$stra"_vals | sed -E "$stra_regex" >> \
            ../"$target"/vals
        grep -H . "$foldr"/*"$stra"_msize | sed -E "$stra_regex" >> \
            ../"$target"/msizes
        grep -H . "$foldr"/*"$stra"_times | sed -E "$stra_regex" >> \
            ../"$target"/times
    done
done

cd ../"$target"

python ../../../tools/plot_matrix.py -hx -ly -sx -sy times times.png \
    "$colors" 'Tiempos v/s $N$' '$P$' '$\mathcal{C}$'

# Collect the values
python ../../../tools/plot_matrix.py -hx -sx -sy vals vals.png \
    "$colors" 'Valor de la sol. v/s $N$' '$P$' '$\mathcal{C}$'

# Collect the number of factories
python ../../../tools/plot_matrix.py -hx -sx -sy nfacs nfacs.png \
    "$colors" 'No. de instalaciones v/s $N$' '$P$' '$\mathcal{C}$'

# Collect the number of factories
python ../../../tools/plot_matrix.py -hx -sx -sy msizes msizes.png \
    "$colors" 'No. de iteraciones v/s $N$' '$P$' '$\mathcal{C}$'

# Create file for the proportions
python ../../../tools/portion_of_max.py greedy vals props
python ../../../tools/plot_matrix.py -np -hx -sx -sy props props.png \
    "$colors" 'Valor respecto a greedy v/s $N$' '$P$' '$\mathcal{C}$'
