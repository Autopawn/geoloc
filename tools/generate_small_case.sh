# TODO: Make this utility save files elsewhere...
# NOTE: If used, remember to modify the image descriptions in the documents.

python3 tools/problem_generator.py deesu 10 15 1000 1000 600 1 cases/small_case.txt cases/small_case_pos.txt

./geoloc.exe 1000 100 10 cases/small_case.txt results/small_case_sol.txt

python3 tools/svg_generator.py cases/small_case_pos.txt tex/figures/small_case_raw.svg

python3 tools/svg_generator.py cases/small_case_pos.txt results/small_case_sol.txt tex/figures/small_case_sol.svg

convert tex/figures/small_case_raw.svg tex/figures/small_case_raw.png
convert tex/figures/small_case_sol.svg tex/figures/small_case_sol.png
