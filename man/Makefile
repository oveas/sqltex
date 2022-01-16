.PHONY: all distdir
DISTFILES = Makefile SQLTeX.1

all : 

distdir : ${DISTFILES}
	cp ${DISTFILES} $(distdir)

install: SQLTeX.1
	cp $^ ${mandir}/man1
