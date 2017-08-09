clean:
	rm geoloc.pdf || true
	rm *.exe || true
	rm vgcore.* || true
hstest:
	cd hs_src; ghc -O2 Test.hs -o ../htest.exe
ctest:
	cd c_src; gcc -Wall -lm \
		../lib/avltree/avltree.c geoloc.c test.c -o ../ctest.exe
ctesttest:
	cd c_src; gcc -g -Wall -lm \
		../lib/avltree/avltree.c geoloc.c test.c -o ../ctest.exe
	valgrind --tool=memcheck --leak-check=yes ./ctest.exe
document:
	cd tex; pdflatex 00main.tex
	cd tex; asy *.asy
	cd tex; bibtex 00main
	cd tex; pdflatex 00main.tex
	cd tex; pdflatex 00main.tex
	mv tex/00main.pdf geoloc.pdf
