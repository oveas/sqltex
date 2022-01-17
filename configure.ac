#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])

m4_include([aclocal/ax_prog_perl_modules.m4])

AC_INIT([SQLTeX], [2.1], [support@oveas.com])

AM_INIT_AUTOMAKE

AX_PROG_PERL_MODULES(DBI Getopt::Long Term::ReadKey, , )

AC_CONFIG_FILES([Makefile src/Makefile doc/Makefile man/Makefile])

AC_OUTPUT
