SQLTeX v2.1
===========

**SQLTeX** is a preprocessor to enable the use of SQL statements in LaTeX. It is a
perl script that reads an input file containing the SQL commands, and writes a
LaTeX file that can be processed with your LaTeX package.

The SQL commands will be replaced by their values. It's possible to select a
single field for substitution substitution in your LaTeX document, or to be
used as input in another SQL command.

When an SQL command returns multiple fields and or rows, the values can only be
used for substitution in the document.

Installing SQLTeX
-----------------

### Linux ###

On a linux system, download the archive and unpack:

    $ tar vxzf sqltex-2.1.tar.gz
    $ cd sqltex-2.1

Next, install **SQLTeX** with the following commands:

    $ ./configure [options]
    $ make
    $ sudo make install

The _`options`_ in `configure` are optional. For an overview of available options
type:

    $ ./configure --help


### Other operating systems ###


#### Windows ####

This distribution contains an .EXE file that was generated using `PAR::Packer`
with Strawberry Perl.

The files `sqltex-2.1\SQLTeX.EXE`, `sqltex-2.1\src\SQLTeX.cfg` and `sqltex-2.1\src\SQLTeX_r.dat` must be placed manually
in the directory of your choice, all in the same direcrtory.

#### OpenVMS ####

For other operating systems, there is no install script, you will have to install
it manually.

On OpenVMS it would be something like:

    $ COPY [.SQLTEX-2_1.SRC]SQLTEX.PL SYS$SYSTEM:
    $ COPY [.SQLTEX-2_1.SRC]SQLTEX.CFG SYS$SYSTEM:
    $ COPY [.SQLTEX-2_1.SRC]SQLTEX_R.DAT SYS$SYSTEM:
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
* **Ingo Reich**       for the comment on Mac OS
* **Johan W. Klüwer**  for verifying the SyBase support
* **Paolo Cavallini**  for adding PostgreSQL support

----------

The **SQLTeX** project is available from [GitHub](https://github.com/oveas/sqltex).

For bugs, questions and comments, please use the [issue tracker](https://github.com/oveas/sqltex/issues)

This software is subject to the terms of the LaTeX Project Public License; 
see [http://www.ctan.org/tex-archive/help/Catalogue/licenses.lppl.html](http://www.ctan.org/tex-archive/help/Catalogue/licenses.lppl.html)
  
Copyright (c) 2001-2022 - Oscar van Eijk, Oveas Functionality Provider

