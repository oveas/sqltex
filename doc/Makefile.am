# Automake makefile for the documentation

.PHONY: all

DISTFILES = Makefile.am Makefile.in SQLTeX.pdf SQLTeX.tex

all : 

distdir : ${DISTFILES}
	cp ${DISTFILES} $(distdir)

SQLTeX.pdf: SQLTeX.tex
	@pdflatex $^

install: SQLTeX.pdf
	@if [ ! -d ${pdfdir} ]; then mkdir -p ${pdfdir}; fi
	cp $^ ${pdfdir}
