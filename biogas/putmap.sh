#
# bash -xe file.svg fileout.png
for fil in res_normal/*.svg; do
	pngname=${fil%.svg}_pass.png
	cat "$fil" | head -n -1 > tmp.svg
	cat "$fil" | grep 'fill="blue"' >> tmp.svg
	echo "</svg>" >> tmp.svg
	sed -i -e 's/width="7" height="7" fill="blue"/width="17" height="17" fill="blue" transform="translate(-5 -5)"/' tmp.svg
	sed -i -e 's/fill="blue"/fill="yellow"/' tmp.svg
	sed -i -e 's/fill-opacity="0.75"/fill-opacity="1.0"/' tmp.svg
	#sed -i -e 's/stroke-width="2" stroke="black"/stroke-width="4" stroke="black"/' tmp.svg
	sed -i -e 's/stroke-width="2"\/>/stroke-width="3"\/>/' tmp.svg
	inkscape --export-png="$pngname" tmp.svg
	convert map_comp.png -flip "$pngname" -composite -flip "${fil%.svg}.png"
	rm "$pngname"
	rm tmp.svg
done
