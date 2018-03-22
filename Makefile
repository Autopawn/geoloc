geoloc_all: geoloc geoloc_hausdorff geoloc_pairs geoloc_vrtest
clean:
	mkdir -p results
	rm geoloc.pdf || true
	rm *.exe || true
	rm vgcore.* || true
hstest:
	cd hs_src; ghc -O2 Test.hs -o ../htest.exe
geoloc:
	cd c_src; gcc -std=c99 -O -Wall -lm geoloc.c load.c main.c \
		-o ../geoloc.exe
geoloc_hausdorff:
	cd c_src; gcc -std=c99 -O -Wall -lm geoloc.c load.c main.c \
		-D HAUSDORFF -o ../geoloc_hausdorff.exe
geoloc_verbose:
	cd c_src; gcc -std=c99 -O -Wall -lm geoloc.c load.c main.c \
		-D VERBOSE -o ../geoloc_verbose.exe
geoloc_pairs:
	cd c_src; gcc -std=c99 -O -Wall -lm geoloc.c load.c main.c \
		-D VERBOSE -D PAIR_DISTANCE -D PRINT_EXPANSIONS \
		-o ../geoloc_pairs.exe
geoloc_vrtest:
	cd c_src; gcc -std=c99 -O -Wall -lm geoloc.c load.c main.c \
		-D EXTENSIVE_VR_TEST_STEP=50 -D EXTENSIVE_VR_TEST_MAX=2000 \
		-o ../geoloc_vrtest.exe
geoloc_test: clean
	cd c_src; gcc -std=c99 -O -g -Wall -lm geoloc.c load.c main.c -o ../geoloc.exe
	valgrind --tool=memcheck --leak-check=yes ./geoloc.exe 1000 100 10 cases/case_1.txt results/geoloc_test.txt
