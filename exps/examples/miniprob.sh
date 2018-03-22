#python ../../tools/prob_generator.py 30 6 1000 500 400 1 miniprob
python ../../tools/prob_translator.py miniprob geoloc miniprob_geo
../../geoloc_pairs.exe 3 4 10 miniprob_geo miniprob_sol
python ../../tools/svg_generator.py miniprob -l miniprob.svg
