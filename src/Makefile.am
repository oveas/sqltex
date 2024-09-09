# Automake makefile for the SQLTeX code and configfiles

.PHONY: distdir
DATAFILES = SQLTeX_r.dat SQLTeX.cfg
DISTFILES = Makefile.am Makefile.in sqltex ${DATAFILES}

PL=$(shell which perl)

all : sqltex.pl

distdir : ${DISTFILES}
	cp $(DISTFILES) $(distdir)

sqltex.pl: sqltex
	cat $^ | sed -e 's#!/usr/bin/env perl#!$(PL)#;s#/usr/local/etc#$(sysconfdir)#' > $@
	@chmod +x $@

install : sqltex.pl ${DATAFILES}
	@if [ ! -d ${bindir} ]; then mkdir -p ${bindir}; fi
	@if [ ! -d ${sysconfdir} ]; then mkdir -p ${sysconfdir}; fi
	@if [ -f $(bindir)/SQLTeX ]; then rm $(bindir)/SQLTeX; fi
	cp $< $(bindir)/sqltex
	ln -s $(bindir)/sqltex $(bindir)/SQLTeX
	@$(foreach datafile, $(DATAFILES), \
		if [ -e $(sysconfdir)/$(datafile) ]; \
			then echo 'cp $(datafile) $(sysconfdir)/$(datafile).new'; \
				cp $(datafile) $(sysconfdir)/$(datafile).new; \
			else echo 'cp $(datafile) $(sysconfdir)/$(datafile)';  \
				cp $(datafile) $(sysconfdir)/$(datafile); \
		fi;)
