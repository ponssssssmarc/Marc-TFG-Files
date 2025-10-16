# Makefile to compile report.tex using latexmk and latexmkrc

TEXFILE=TFG.tex
PDF=$(TEXFILE:.tex=.pdf)

all: $(PDF)

$(PDF): $(TEXFILE)
	latexmk -pdf $(TEXFILE)

clean:
	latexmk -C

.PHONY: all clean