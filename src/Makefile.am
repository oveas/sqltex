# Automake makefile for the SQLTeX code and configfiles

.PHONY: distdir
DATAFILES = SQLTeX_r.dat SQLTeX.cfg
DISTFILES = Makefile.am Makefile.in SQLTeX.pl ${DATAFILES}

PL=$(shell which perl)

all : SQLTeX

distdir : ${DISTFILES}
	cp $(DISTFILES) $(distdir)

SQLTeX: SQLTeX.pl
	cat $^ | sed -e 's#{PERLDIR}#!$(PL)#;s#{SYSCONFDIR}#$(sysconfdir)#' > $@
	@chmod +x $@

install : SQLTeX ${DATAFILES}
	@if [ ! -d ${bindir} ]; then mkdir -p ${bindir}; fi
	@if [ ! -d ${sysconfdir} ]; then mkdir -p ${sysconfdir}; fi
	cp $< $(bindir)
	@$(foreach datafile, $(DATAFILES), \
		if [ -e $(sysconfdir)/$(datafile) ]; \
			then echo 'cp $(datafile) $(sysconfdir)/$(datafile).new'; \
				cp $(datafile) $(sysconfdir)/$(datafile).new; \
			else echo 'cp $(datafile) $(sysconfdir)/$(datafile)';  \
				cp $(datafile) $(sysconfdir)/$(datafile); \
		fi;)
