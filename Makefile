geoloc_all: geoloc geoloc_hausdorff
clean:
	mkdir -p results
	rm geoloc.pdf || true
	rm *.exe || true
	rm vgcore.* || true
hstest:
	cd hs_src; ghc -O2 Test.hs -o ../htest.exe
geoloc:
	cd c_src; gcc -O -Wall -lm geoloc.c load.c main.c -o ../geoloc.exe
geoloc_hausdorff:
	cd c_src; gcc -O -Wall -lm geoloc.c load.c main.c -D HAUSDORFF -o \
		../geoloc_hd.exe
geoloc_verbose:
	cd c_src; gcc -O -Wall -lm geoloc.c load.c main.c -D VERBOSE -o \
		../geoloc.exe
geoloc_test: clean
	cd c_src; gcc -O -g -Wall -lm geoloc.c load.c main.c -o ../geoloc.exe
	valgrind --tool=memcheck --leak-check=yes ./geoloc.exe 1000 100 10 cases/case_1.txt results/geoloc_test.txt
