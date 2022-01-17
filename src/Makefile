.PHONY: distdir
DATAFILES = SQLTeX_r.dat SQLTeX.cfg
DISTFILES = Makefile SQLTeX.pl ${DATAFILES}

PL=$(shell which perl)

all : SQLTeX

distdir : ${DISTFILES}
	cp $(DISTFILES) $(distdir)

SQLTeX: SQLTeX.pl
	cat $^ | sed -e 's#{PERLDIR}#$(PL)#;s#{SYSCONFDIR}#$(sysconfdir)#' > $@
	@chmod +x $@

install : SQLTeX ${DATAFILES}
	@cp $< $(bindir)
	@cp $(DATAFILES) $(sysconfdir)
