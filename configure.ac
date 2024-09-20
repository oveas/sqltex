# Autoconf configfile for SQLTeX.
# To create a new distribution, execute the following steps:
#   aclocal
#   autoconf
#   automake --add-missing
#   ./configure
#   make dist
#
# To install:
#   ./configure [options]
#   make
#   [sudo] make install

AC_PREREQ([2.69])

# Ensure configure can check for the required perl modules.
m4_include([aclocal/ax_prog_perl_modules.m4])

AC_INIT([SQLTeX], [3.0], [support@oveas.com])

AM_INIT_AUTOMAKE

AX_PROG_PERL_MODULES([DBI DBD::mysql Getopt::Long Term::ReadKey]
                    ,
                    ,[AC_MSG_ERROR([Not all required perl modules are installed])]
)

# Makefile to be generated in the subdirectories as well
AC_CONFIG_FILES([Makefile src/Makefile doc/Makefile man/Makefile])

AC_OUTPUT
