
LS="\#!"
PL=$(shell which perl)

all : SQLTeX

SQLTeX: SQLTeX.pl
	@echo "$(LS)$(PL)" > $@
	@cat $@.pl >> $@

