SQLTeX v1.4
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
an installation script for Unix (install), the Perl script SQLTeX and the
default replace file.

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
  $ SET FILE/PROTECTION=(W:RE) SQLTEX.
  $ COPY SQLTEX. SYS$SYSTEM:
  $ COPY SQLTEX_R.DAT. SYS$SYSTEM:
However, on OpenVMS you also need to define the command SQLTEX by setting a symbol,
either in the LOGIN.COM for all users who need to execute this script, or in some
group-- or system wide login procedure, with the command:
  $ SQLTEX :== "PERL SYS$SYSTEM:SQLTEX."
  
For more information, please refer to the LaTeX documentation.


Requirements:
-------------
* Perl        (http://perl.org/)
* Perl-DBI    (http://dbi.perl.org/)
* The DBI driver for your database (see: http://search.cpan.org/search?query=DBD%3A%3A&mode=module)
  

Note for MAC users:
-------------------
If DBI and the database driver are not yet installed, Xtools needs to be
installed in advance, since gcc is not available in a standard install
of Mac OS X.


Thanks to:
==========
Ingo Reich       for the comment on Mac OS
Johan W. Klüwer  for verifying the SyBase support
Paolo Cavallini  for adding PostgreSQL support


Changes:
========
v1.5 (2007-11-23):
- Support for multiple database drivers
- Added NEWLINE directive as row seperator
- Multidocument support
- Implemented updates

v1.4 (2002-05-02):
- Implemented replace files

==========================================================================
The latest release is always available at http://freeware.oveas.com/sqltex
For bugs, questions and comments, please contact me at
oscar.van.eijk@oveas.com

This software is subject to the terms of the LaTeX Project Public License; 
see http://www.ctan.org/tex-archive/help/Catalogue/licenses.lppl.html
  
Copyright (c) 2001-2007 - Oscar van Eijk, Oveas Functionality Provider
==========================================================================

