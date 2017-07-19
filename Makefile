test:
	cd src; ghc -O2 Test.hs -o ../test.exe
document:
	cd tex; pdflatex 00main.tex
	cd tex; asy *.asy
	cd tex; bibtex 00main
	cd tex; pdflatex 00main.tex
	cd tex; pdflatex 00main.tex
	mv tex/00main.pdf geoloc.pdf
