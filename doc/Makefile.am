.PHONY: all
DISTFILES = Makefile.am Makefile.in SQLTeX.pdf

all : 

distdir : ${DISTFILES}
	cp ${DISTFILES} $(distdir)

install: SQLTeX.pdf
	cp $^ ${pdfdir}
