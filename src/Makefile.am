# Automake makefile for the SQLTeX code and configfiles

.PHONY: distdir
DATAFILES = SQLTeX_r.dat SQLTeX.cfg
DISTFILES = Makefile.am Makefile.in SQLTeX ${DATAFILES}

PL=$(shell which perl)

all : SQLTeX.pl

distdir : ${DISTFILES}
	cp $(DISTFILES) $(distdir)

SQLTeX.pl: SQLTeX
	cat $^ | sed -e 's#!/usr/bin/env perl#!$(PL)#;s#{SYSCONFDIR}#$(sysconfdir)#' > $@
	@chmod +x $@

install : SQLTeX.pl ${DATAFILES}
	@if [ ! -d ${bindir} ]; then mkdir -p ${bindir}; fi
	@if [ ! -d ${sysconfdir} ]; then mkdir -p ${sysconfdir}; fi
	cp $< $(bindir)/SQLTeX
	@$(foreach datafile, $(DATAFILES), \
		if [ -e $(sysconfdir)/$(datafile) ]; \
			then echo 'cp $(datafile) $(sysconfdir)/$(datafile).new'; \
				cp $(datafile) $(sysconfdir)/$(datafile).new; \
			else echo 'cp $(datafile) $(sysconfdir)/$(datafile)';  \
				cp $(datafile) $(sysconfdir)/$(datafile); \
		fi;)
