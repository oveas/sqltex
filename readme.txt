SQLTeX v1.3
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
an installation script for Unix (install), and the Perl script SQLTeX. The
last file is all you actually need.

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
However, on OpenVMS you also need to define the command SQLTEX by setting a symbol,
either in the LOGIN.COM for all users who need to execute this script, or in some
group-- or system wide login procedure, with the command:
  $ SQLTEX :== "PERL SYS$SYSTEM:SQLTEX."
  
For more information, please refer to the LaTeX documentation.

==========================================================================
The latest release is always available at http://software.oveas.net/sqltex
For bugs, questions and comments, please contact me at
oscar.van.eijk@oveas.net

Copyright (c) 2001 - Oscar van Eijk, Oveas Internet Services
==========================================================================

DISCLAIMER:
-----------

ANY SOFTWARE PROVIDED BY OVEAS INTERNET SERVICES IS ``AS IS'' AND ANY
EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL OVEAS INTERNET SERVICES OR ITS CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
THIS SCRIPT IS PROVIDED WITHOUT SUPPORT.

THIS SOFWTARE CAN BE USED FREELY FOR NON-COMMERCIAL USE AS LONG AS ALL
COPYRIGHT NOTICES AND DISCLAIMERS ARE NOT REMOVED.
MODIFICATION OF THIS SOFTWARE IS NOT ALLOWED WITHOUT PERMISSION OF THE
COPYRIGHT HOLDERS.
