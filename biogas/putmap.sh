pngname=${1%.svg}_pass.png
inkscape --export-png="$pngname" $1
convert map_comp.png -flip "$pngname" -composite -flip $2
rm "$pngname"
