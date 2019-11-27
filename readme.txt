SQLTeX v2.0
===========

SQLTeX is a preprocessor to enable the use of SQL statements in LaTeX.
It is a perl script that reads an input file containing the SQL commands,
and writes a LaTeX file that can be processed with your LaTeX package.

The SQL commands will be replaced by their values. It's possible to select
a single field for substitution substitution in your LaTeX document, or to
be used as input in another SQL command.

When an SQL command returns multiple fields and or rows, the values can only
be used for substitution in the document.

Installing SQLTeX
-----------------
Before installing SQLTeX, you need to have it. The latest version can always
be found at http://software.oveas.net/sqltex.
The download consists of this readme, documentation in LaTeX and HTML format,
an installation script for Unix (install), the Perl script SQLTeX, the
default replace- and configuration files, and the Windows executable.

On a Unix system, make sure the file install is executable by issueing
the command:
  bash$ chmod +x install
then execute it with:
  bash$ ./install

The script will ask in which directory SQLTeX should be installed. If you are
logged in as `root', the default will be /usr/local/bin, otherwise the
current directory.
Make sure the directory where SQLTeX is installed is in your path.

For other operating systems, there is no install script, you will have to install
it manually.

On OpenVMS it would be something like:
  $ COPY SQLTEX.PL SYS$SYSTEM:
  $ COPY SQLTEX.CFG SYS$SYSTEM:
  $ COPY SQLTEX_R.DAT SYS$SYSTEM:
  $ SET FILE/PROTECTION=(W:R) SYS$SYSTEM:SQLTEX*.*
However, on OpenVMS you also need to define the command SQLTEX by setting a symbol,
either in the LOGIN.COM for all users who need to execute this script, or in some
group-- or system wide login procedure, with the command:
  $ SQLTEX :== "PERL SYS$SYSTEM:SQLTEX.PL"
  
For more information, please refer to the LaTeX documentation.


Requirements:
-------------
* Perl          (http://perl.org/)
* Perl-DBI      (http://dbi.perl.org/)
* The DBI driver for your database (see: http://search.cpan.org/search?query=DBD%3A%3A&mode=module)
* Getopt::Std   (https://metacpan.org/pod/Term::ReadKey)
* Term::ReadKey (https://metacpan.org/pod/Term::ReadKey)

Note for MAC users:
-------------------
If DBI and the database driver are not yet installed, Xtools needs to be
installed in advance, since gcc is not available in a standard install
of Mac OS X.


Note for Windows users:
-----------------------
This distribution contains an .EXE file that was generated using PAR::Packer with
Strawberry Perl.
The files SQLTeX.EXE, SQLTeX.cfg and SQLTeX-r.dat must be placed manually in the
directory of your choice, all in the same direcrtory.


Thanks to:
==========
Ingo Reich       for the comment on Mac OS
Johan W. Klüwer  for verifying the SyBase support
Paolo Cavallini  for adding PostgreSQL support

==========================================================================
The SQL\TeX\ project is available from GitHub:
    https://github.com/oveas/sqltex
The latest stable release is always available at
    http://oveas.com/freeware/overige/sqltex
For bugs, questions and comments, please use the issue tracker available at
    https://github.com/oveas/sqltex/issues

This software is subject to the terms of the LaTeX Project Public License; 
see http://www.ctan.org/tex-archive/help/Catalogue/licenses.lppl.html
  
Copyright (c) 2001-2016 - Oscar van Eijk, Oveas Functionality Provider
==========================================================================

