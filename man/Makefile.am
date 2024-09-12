# Automake makefile for the linux manpage

.PHONY: all distdir
DISTFILES = Makefile.am Makefile.in sqltex.man

all : 

sqltex.1 : sqltex.man
	@cat $^ | sed -e 's#{BINDIR}#$(bindir)#;s#{SYSCONFDIR}#$(sysconfdir)#' > $@

distdir : ${DISTFILES}
	cp ${DISTFILES} $(distdir)

install: sqltex.1
	@if [ ! -d ${mandir} ]; then mkdir -p ${mandir}; fi
	cp $^ ${mandir}/man1
