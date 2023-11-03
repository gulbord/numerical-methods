.PHONY: nmsm.pdf all clean

all: nmsm.pdf

nmsm.pdf: nmsm.tex
	latexmk -silent -pdf -pdflatex='pdflatex -halt-on-error -synctex=1' -use-make nmsm

clean:
	latexmk -c
	rm -f ./*/*.aux *.bbl
