clean:
	mkdir -p results
	rm geoloc.pdf || true
	rm *.exe || true
	rm vgcore.* || true
hstest:
	cd hs_src; ghc -O2 Test.hs -o ../htest.exe
geoloc:
	cd c_src; gcc -O -Wall -lm geoloc.c load.c main.c -o ../geoloc.exe
geoloc_verbose:
	cd c_src; gcc -O -Wall -lm geoloc.c load.c main.c -D VERBOSE -o \
		../geoloc.exe
geoloc_test: clean
	cd c_src; gcc -O -g -Wall -lm geoloc.c load.c main.c -o ../geoloc.exe
	valgrind --tool=memcheck --leak-check=yes ./geoloc.exe 1000 100 10 cases/case_1.txt results/geoloc_test.txt
document:
	cd tex; pdflatex 00main.tex
	cd tex; asy *.asy
	cd tex; bibtex 00main
	cd tex; pdflatex 00main.tex
	cd tex; pdflatex 00main.tex
	mv tex/00main.pdf geoloc.pdf
