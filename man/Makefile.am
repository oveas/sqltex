# Automake makefile for the linux manpage

.PHONY: all distdir
DISTFILES = Makefile.am Makefile.in SQLTeX.man

all : 

SQLTeX.1 : SQLTeX.man
	cat $^ | sed -e 's#{BINDIR}#$(bindir)#;s#{SYSCONFDIR}#$(sysconfdir)#' > $@

distdir : ${DISTFILES}
	cp ${DISTFILES} $(distdir)

install: SQLTeX.1
	cp $^ ${mandir}/man1
