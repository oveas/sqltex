SQLTeX v3.0
===========

**SQLTeX** is a preprocessor to enable the use of SQL statements in LaTeX. It is a
perl script that reads one or more input files containing the SQL commands, and writes a
single LaTeX file or multiple files based on the data read from the database.
Those files can be processed with your LaTeX package.

The SQL commands will be replaced by their values. It's possible to select a
single field for substitution substitution in your LaTeX document, or to be
used as input in another SQL command.

### Features ###

* Replace the SQL statements with their result. This can be a single field, a row or multiple rows,
* Configurable replace file to translate special characters or strings to LaTeX format, with support for regular expressions,
* Use info read from the database as input for new SQL statements,
* Process parts of the LaTeX input file in a loop generating multiple pages or documents,
* Write updates to the database when data has been processed,
* Process parts of the document conditionally using `\sqlif` and `\sqlendif` commands,
* Process data by external scripts and use the output with the `\sqlsystem` command (by default disabled in the config file),

and more.

### Supported databases ###

* MySQL/MariaDB
* Sybase
* Oracle
* PostgreSQL
* MSSQL

ODBC is supported.

Others database (Ingres, mSQL, ...) '*should work*'&trade;  but haven´t been tested.

Installing SQLTeX
-----------------

Since version 3.0, **SQLTeX** is part of **TeX Live** and doesn't need further installation.

If you are using a different LaTeX distro, please follow the steps below for your OS.

### Linux ###

On a linux system, download the archive and unpack:

    $ tar vxzf sqltex-3.0.tar.gz
    $ cd sqltex-3.0

Next, install **SQLTeX** with the following commands:

    $ ./configure [options]
    $ make
    $ sudo make install

The *options* in `configure` are optional. For an overview of available options
type:

    $ ./configure --help


### Other operating systems ###


#### Windows ####

The files `sqltex-3.0\sqltex`, `sqltex-3.0\src\SQLTeX.cfg` and `sqltex-3.0\src\SQLTeX_r.dat` must be placed manually
in the directory of your choice, all in the same directory.

Since v3.0 the `SQLTeX.EXE` binary is no longer provided in the distribution.

#### OpenVMS ####

For other operating systems, there is no install script, you will have to install
it manually.

On OpenVMS it would be something like:

    $ COPY [.SQLTEX-3_0.SRC]SQLTEX. SYS$SYSTEM:SQLTEX.PL
    $ COPY [.SQLTEX-3_0.SRC]SQLTEX.CFG SYS$SYSTEM:
    $ COPY [.SQLTEX-3_0.SRC]SQLTEX_R.DAT SYS$SYSTEM:
    $ SET FILE/PROTECTION=(W:R) SYS$SYSTEM:SQLTEX*.*

However, on OpenVMS you also need to define the command SQLTEX by setting a
symbol, either in the LOGIN.COM for all users who need to execute this script,
or in some group-- or system wide login procedure, with the command:

    $ SQLTEX :== "PERL SYS$SYSTEM:SQLTEX.PL"

Documentation
-------------
Full documentation is in `doc/SQLTeX.pdf`.

On linux, this file will be placed in `/usr/share/doc/sqltex` by `make install`.
This location can be changed with the _options_ in the `./configure` step.

Requirements
------------
* [Perl](http://perl.org/) (>v5.10) 
* [Perl-DBI](http://dbi.perl.org/)
* [The DBI driver for your database](http://search.cpan.org/search?query=DBD%3A%3A&mode=module)
* [Getopt::Long](https://metacpan.org/pod/Getopt::Long)
* [Term::ReadKey](https://metacpan.org/pod/Term::ReadKey)

Note for MAC users
------------------
If DBI and the database driver are not yet installed, Xtools needs to be
installed in advance, since gcc is not available in a standard install of Mac OS X.


Credits
-------
* **Karl Berry**       for integration in TeX Live
* **Ingo Reich**       for the comment on Mac OS
* **Johan W. Klüwer**  for verifying the SyBase support
* **Paolo Cavallini**  for adding PostgreSQL support
* **Silpa Suresh**     for testing the ODBC support

----------

The **SQLTeX** project is available from [GitHub](https://github.com/oveas/sqltex).

For bugs, questions and comments, please use the [issue tracker](https://github.com/oveas/sqltex/issues)

Copyright (c) 2001-2024 - Oscar van Eijk, Oveas Functionality Provider

This software is subject to the terms of the LaTeX Project Public License; 
see [http://www.ctan.org/tex-archive/help/Catalogue/licenses.lppl.html](http://www.ctan.org/tex-archive/help/Catalogue/licenses.lppl.html)
  

