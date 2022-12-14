#{PERLDIR}

################################################################################
#
# SQLTeX - SQL preprocessor for Latex
#
# File:		SQLTeX
# =====
#
# Purpose:	This script is a preprocessor for LaTeX. It reads a LaTeX file
# ========	containing SQL commands, and replaces them their values.
#
# This software is subject to the terms of the LaTeX Project Public License; 
# see http://www.ctan.org/tex-archive/help/Catalogue/licenses.lppl.html.
#
# Copyright:  (c) 2001-2022, Oscar van Eijk, Oveas Functionality Provider
# ==========                 oscar@oveas.com
#
# History:
# ========
#   v1.3     Mar 16, 2001 (Initial release)
#   v1.4     May  2, 2002
#   v1.4.1   Feb 15, 2005
#   v1.5     Nov 23, 2007
#   v2.0     Jan 12, 2016
#   v2.1     Jan 21, 2022
#   v2.1-1   Apr 19, 2022 (test version for MSSQL, no official release)
# Refer to the documentation for changes per release
#
# TODO:
# =====
# Code is getting messy - too many globals: rewrite required
#
################################################################################
#
use strict;
use DBI;
use Getopt::Long;
use Term::ReadKey;
Getopt::Long::Configure ("bundling");
use feature 'state';

#####
# Check if we're running on linux
#
sub is_linux {
	return ($^O eq "linux");
}

#####
# Check if we're running on windows
#
sub is_windows {
	return ($^O eq "MSWin32");
}

#####
# Find out if any command-line options have been given
# Parse them using 'Getopt'
#
sub parse_options {

	$main::NULLallowed = 0;

	if (!GetOptions('help|h|?' => \$main::options{'h'}
		, 'configfile|c=s' => \$main::options{'c'}
		, 'replacementfile|r=s' => \$main::options{'r'}
		, 'no-replacementfile|R' => \$main::options{'R'}
		, 'output|o=s' => \$main::options{'o'}
		, 'filename-extend|e=s' => \$main::options{'e'}
		, 'file-extension|E=s' => \$main::options{'E'}
		, 'sqlserver|s=s' => \$main::options{'s'}
		, 'username|U=s' => \$main::options{'U'}
		, 'password|P:s' => \$main::options{'P'}
		, 'null-allowed|N' => \$main::options{'N'}
		, 'version|V' => \$main::options{'V'}
		, 'force|f' => \$main::options{'f'}
		, 'quiet|q' => \$main::options{'q'}
		, 'multidoc-numbered|m' => \$main::options{'m'}
		, 'multidoc-named|M' => \$main::options{'M'}
		, 'prefix|p=s' => \$main::options{'p'}
		, 'use-local-config|l' => \$main::options{'l'}
		, 'updates|u' => \$main::options{'u'}
	)) {
		print "usage: $main::myself [options] <file[.$main::configuration{'texex'}]> [parameter...]\n"
			. "       type \"$main::myself --help\" for help\n";
		exit(1);
	}

	if (defined $main::options{'h'}) {
		&print_help;
		exit(0);
	}
	if (defined $main::options{'V'}) {
		&print_version;
		exit(0);
	}

	my $optcheck = 0;
	$optcheck++ if (defined $main::options{'E'});
	$optcheck++ if (defined $main::options{'e'});
	$optcheck++ if (defined $main::options{'o'});
	die ("options \"-E\", \"-e\" and \"-o\" cannot be combined\n") if ($optcheck > 1);

	$optcheck = 0;
	$optcheck++ if (defined $main::options{'m'});
	$optcheck++ if (defined $main::options{'M'});
	$optcheck++ if (defined $main::options{'o'});
	die ("options \"-m\", \"-M\" and \"-o\" cannot be combined\n") if ($optcheck > 1);

	$optcheck = 0;
	$optcheck++ if (defined $main::options{'r'});
	$optcheck++ if (defined $main::options{'R'});
	die ("options \"-r\" and \"-R\" cannot be combined\n") if ($optcheck > 1);

	$main::NULLallowed = 1 if (defined $main::options{'N'});
	$main::configuration{'cmd_prefix'} = $main::options{'p'} if (defined $main::options{'p'});

	$main::multidoc_cnt = 0;
	$main::multidoc = (defined $main::options{'m'} || defined $main::options{'M'});
	$main::multidoc_id = '';

	if ($main::multidoc) {
		$main::multidoc_id = '_#M#';
		if (defined $main::options{'M'}) {
			$main::multidoc_id = '_#P#'
		}
	}

	if (defined $main::options{'l'} && !&is_linux) {
		warn "Option \"-l\" is ignored on $^O";
		delete $main::options{'l'};
	}
}

#####
# Print the Usage: line on errors and after the '-h' switch
#
sub short_help ($) {
	my $onerror = shift;
	my $helptext = "usage: $main::myself [options] <file[.$main::configuration{'texex'}]> [parameter...]\n";
	$helptext .= "       type \"$main::myself -h\" for help\n" if ($onerror);
	return ($helptext);
}


#####
# Print full help and after the '-h' switch
#
sub print_help {
	my $helptext = &short_help (0);

	$helptext .= "       Options:\n";
	$helptext .= "       --configfile <file>\n";
	$helptext .= "       -c <file>\n";
	$helptext .= "            SQLTeX configuration file.\n";
	$helptext .= "            Default is \'$main::config_location/SQLTeX.cfg\'.\n";
	$helptext .= "       --file-extension <string>\n";
	$helptext .= "       -E <string>\n";
	$helptext .= "            replace input file extension in outputfile:\n";
	$helptext .= "            \'input.tex\' will be \'input.string\'\n";
	$helptext .= "            For further notes, see option \'--filename-extend\' below\n";
	$helptext .= "       --null-allowed\n";
	$helptext .= "       -N\n";
	$helptext .= "            NULL return values allowed. By default SQLTeX exits if a\n";
	$helptext .= "            query returns an empty set\n";
	$helptext .= "       --password [password]\n";
	$helptext .= "       -P [password]\n";
	$helptext .= "            database password. The value is optional; if omitted, SQLTeX will prompt for\n";
	$helptext .= "            a password. This overwrites the password in the input file.\n";
	$helptext .= "       --username <user>\n";
	$helptext .= "       -U <user>\n";
	$helptext .= "            database username\n";
	$helptext .= "       --version\n";
	$helptext .= "       -V\n";
	$helptext .= "            print version number and exit\n";
	$helptext .= "       --filename-extend <string>\n";
	$helptext .= "       -e <string>\n";
	$helptext .= "            add string to the output filename:\n";
	$helptext .= "               \'input.tex\' will be \'inputstring.tex\'\n";
	$helptext .= "               In \'string\', the values between curly braces \{\}\n";
	$helptext .= "                 will be substituted:\n";
	$helptext .= "                 Pn      parameter n\n";
	$helptext .= "                 M       current monthname (Mon)\n";
	$helptext .= "                 W       current weekday (Wdy)\n";
	$helptext .= "                 D       current date (yyyymmdd)\n";
	$helptext .= "                 DT      current date and time (yyyymmddhhmmss)\n";
	$helptext .= "                 T       current time (hhmmss)\n";
	$helptext .= "               e.g., the command \'$main::myself --filename-extend _{P1}_{W} my_file code\'\n";
	$helptext .= "               will read \'my_file.tex\' and write \'myfile_code_Tue.tex\'\n";
	$helptext .= "               The same command, but with option \--file-extension\' would create the\n";
	$helptext .= "               outputfile \'myfile._code_Tue\'\n";
	$helptext .= "               By default the outputfile \'myfile_stx.tex\' would have been written.\n";
	$helptext .= "               The options \'--file-extension\' and \'--filename-extend\' cannot be used\n";
	$helptext .= "               together or with \'--output\'.\n";
	$helptext .= "       --force\n";
	$helptext .= "       -f\n";
	$helptext .= "               force overwrite of existing files\n";
	$helptext .= "       --help\n";
	$helptext .= "       -h\n";
	$helptext .= "               print this help message and exit\n";
	$helptext .= "       --multidoc-numbered\n";
	$helptext .= "       -m\n";
	$helptext .= "               Multidocument mode; create one document for each parameter that is retrieved\n";
	$helptext .= "               from the database in the input document (see documentation)\n";
	$helptext .= "               This option cannot be used with \'--output\'.\n";
	$helptext .= "       --multidoc-named\n";
	$helptext .= "       -M\n";
	$helptext .= "               Same as -m, but with the parameter in the filename i.s.o. a serial number\n";
	$helptext .= "       --output <file>\n";
	$helptext .= "       -o <file>\n";
	$helptext .= "               specify an output file. Cannot be used with \'--file-extension\',\n";
	$helptext .= "               \'--filename-extend\' or the \'--multidoc\' options.\n";
	$helptext .= "       --prefix <prefix>\n";
	$helptext .= "       -p <prefix>\n";
	$helptext .= "               prefix used in the SQLTeX file. Default is \'sql\'\n";
	$helptext .= "               (e.g. \\sqldb[user]{database}), but this can be overwritten if it conflicts\n";
	$helptext .= "               with other user-defined commands.\n";
	$helptext .= "       --quiet\n";
	$helptext .= "       -q\n";
	$helptext .= "               run in quiet mode\n";
	$helptext .= "       --replacementfile <file>\n";
	$helptext .= "       -r <file>\n";
	$helptext .= "               specify a file that contains replace characters. This is a list with two tab-separated\n";
	$helptext .= "               fields per line. The first field holds a string that will be replaced in the SQL output\n";
	$helptext .= "               by the second string.\n";
	$helptext .= "               By default the file \'$main::config_location/SQLTeX_r.dat\' is used.\n";
	$helptext .= "       --no-replacementfile\n";
	$helptext .= "       -R\n";
	$helptext .= "               do not use a replace file. \'--replacementfile\' \'--no-replacementfile\' are handled\n";
	$helptext .= "               in the same order as they appear on the command line.\n";
	$helptext .= "               For backwards compatibility, -rn is also still supported.\n";

	if (&is_linux) {
		$helptext .= "       --use-local-config\n";
		$helptext .= "       -l\n";
		$helptext .= "               use $main::my_location as default location for the config- and replacement files\n";
		$helptext .= "               in stead of $main::config_location.\n";
	}

	$helptext .= "       --sqlserver <server>\n";
	$helptext .= "       -s <server>\n";
	$helptext .= "               SQL server to connect to. Default is \'localhost\'\n";
	$helptext .= "       --updates\n";
	$helptext .= "       -u\n";
	$helptext .= "               If the input file contains updates, execute them.\n";

	$helptext .= "\n       file          is the input file that should be read. By default,\n";
	$helptext .= "                     $main::myself looks for a file with extension \'.$main::configuration{'texex'}\'.\n";
	$helptext .= "\n       parameter(s)  are substituted in the SQL statements if they contain\n";
	$helptext .= "                     the string \$PAR[x] somewhere in the statement, where\n";
	$helptext .= "                     \'x\' is the number of the parameter.\n";

	print $helptext;
}

#####
# Print the version number
#
sub print_version {
	print "$main::myself v$main::version - $main::rdate\n";
}

#####
# If we're not running in quiet mode (-q), this routine prints a message telling
# the user what's going on.
#
sub print_message ($) {
	my $message = shift;
	print "$message\n" unless (defined $main::options{'q'});
}


#####
# If we have to prompt for a password, disable terminal echo, get the password
# and return it to the caller
#
sub get_password ($$) {
	my ($usr, $srv) = @_;

	my $pwd = "";

	print "Password for $usr\@$srv : ";

	ReadMode(4);
	while(ord(my $keyStroke = ReadKey(0)) != 10) {
		if(ord($keyStroke) == 127 || ord($keyStroke) == 8) { # DEL/Backspace
			chop($pwd);
			print "\b \b";
		} elsif(ord($keyStroke) >= 32) { # Skip control characters
			$pwd = $pwd . $keyStroke;
			print '*';
		}
	}
	ReadMode(0);

	return $pwd;
}

#####
# If we have to prompt for a user. Get it and return it to the caller
#
sub get_username ($) {
	my $srv = shift;

	print "Username at $srv : ";

	my $usr = <STDIN>;
	chomp $usr;
	return $usr;
}


#######
# Find the file extension for the outputfile
#
sub file_extension ($) {
	my $subst = shift;

	my %mn = ('Jan','01', 'Feb','02', 'Mar','03', 'Apr','04',
		  'May','05', 'Jun','06', 'Jul','07', 'Aug','08',
		  'Sep','09', 'Oct','10', 'Nov','11', 'Dec','12' );
	my $sydate = localtime (time);
	my ($wday, $mname, $dnum, $time, $year) = split(/\s+/,$sydate);
	$dnum = "0$dnum" if ($dnum < 10);
	while ($subst =~ /\{[a-zA-Z0-9]+\}/) {
		my $s1  = $`;
		my $sub = $&;
		my $s2  = $';
		$sub =~ s/[\{\}]//g;
		if ($sub =~ /P[0-9]/) {
			$sub =~ s/P//;
			die ("insufficient parameters to substitute \{P$sub\}\n") if ($sub > $#ARGV);
			$sub = $ARGV[$sub];
		} elsif ($sub eq 'M') {
			$sub = $mname;
		} elsif ($sub eq 'W') {
			$sub = $wday;
		} elsif ($sub eq 'D') {
			$sub = "$year$mn{$mname}$dnum";
		} elsif ($sub eq 'DT') {
			$sub = "$year$mn{$mname}$dnum$time";
			$sub =~ s/://g;
		} elsif ($sub eq 'T') {
			$sub = $time;
			$sub =~ s/://g;
		} else  {
			die ("unknown substitution code \{$sub\}\n");
		}
		$subst = "$s1$sub$s2";
	}
	return ($subst);
}

#####
# Find the configuration files
#
sub get_configfiles {
	if (defined $main::options{'c'}) {
		$main::configurationfile = $main::options{'c'};
	} else {
		$main::configurationfile = $main::config_location
			. ($main::config_location eq '' ? '' : '/')
			. 'SQLTeX.cfg';
	}
	if (!-e $main::configurationfile) {
		die ("Configfile $main::configurationfile does not exist\n");
	}
	
	if (defined $main::options{'r'}) {
		$main::replacefile = $main::options{'r'};
	} else {
		$main::replacefile = $main::config_location
			. ($main::config_location eq '' ? '' : '/')
			. 'SQLTeX_r.dat'
			unless (defined $main::options{'R'});
	}
	if (defined $main::replacefile && !-e $main::replacefile) {
		warn ("replace file $main::replacefile does not exist\n") unless ($main::replacefile eq "n");
		undef $main::replacefile;
	}
	
	return;
}

#####
# Declare the filenames to use in this run.
# If a file has been entered 
#
sub get_filenames {
	$main::inputfile = $ARGV[0] || die "no input file specified\n";

	$main::path = '';
	while ($main::inputfile =~ /\//) {
		$main::path .= "$`/";
		$main::inputfile =~ s/$`\///;
	}
	if ($main::inputfile =~/\./) {
		if ((!-e "$main::path$main::inputfile") && (-e "$main::path$main::inputfile.$main::configuration{'texex'}")) {
			$main::inputfile .= ".$main::configuration{'texex'}";
		}
	} else {
		$main::inputfile .= ".$main::configuration{'texex'}"
	} 
	die "File $main::path$main::inputfile does not exist\n" if (!-e "$main::path$main::inputfile");

	if (!defined $main::options{'o'}) {
		$main::inputfile =~ /\./;
		$main::outputfile = "$`";
		my $lastext = "$'";
		while ($' =~ /\./) {
			$main::outputfile .= ".$`";
			$lastext = "$'";
		}
		if (defined $main::options{'E'} || defined $main::options{'e'}) {
			$main::configuration{'stx'} = &file_extension ($main::options{'E'} || $main::options{'e'});
		}
		if (defined $main::options{'E'}) {
			$main::outputfile .= "$main::multidoc_id.$main::configuration{'stx'}";
		} else {
			$main::outputfile .= "$main::configuration{'stx'}$main::multidoc_id\.$lastext";
		}
		if ($main::configuration{'def_out_is_in'}) {
			$main::outputfile = $main::path . $main::outputfile;
		}
	} else {
		$main::outputfile = $main::options{'o'};
		if ($main::configuration{'def_out_is_in'} && !($main::outputfile =~ /\//)) {
			$main::outputfile = $main::path . $main::outputfile;
		}
	}

	return;
}

#######
# Connect to the database
#
sub db_connect($$) {
	my ($up, $db) = @_;
	state $data_source;
	state $gotInput = 0;

	$main::line =~ s/(\[.*?\])?\{$db\}//;

	state $un = '';
	state $pw = '';
	state $hn = '';

	if (!$gotInput) {
		my @opts = split(',', $up);
		for(my $idx = 0; $idx <= $#opts; $idx++) {
			my $opt = $opts[$idx];
			if ($opt =~ /=/) {
				if ($` eq 'user') {
					$un = $';
				} elsif ($` eq 'passwd') {
					$pw = $';
				} elsif ($` eq 'host') {
					$hn = $';
				}
			} else {
				if ($idx == 0) {
					$un = $opt;
				} elsif ($idx == 1) {
					$pw = $opt;
				} elsif ($idx == 2) {
					$hn = $opt;
				}
			}
		}

		$un = $main::options{'U'} if (defined $main::options{'U'});
		$un = &get_username($main::options{'s'} || 'localhost') if ($un eq '?');

		my $promptForPwd = 0;
		if (defined $main::options{'P'}) {
			if ($main::options{'P'} eq '') {
				$promptForPwd = 1;
			} else {
				$pw = $main::options{'P'}
			}
		}
		if ($pw eq '?') {
			$promptForPwd = 1;
		}
		$pw = &get_password ($un, $main::options{'s'} || 'localhost') if ($promptForPwd);
		$gotInput = 1;

		$hn = $main::options{'s'} if (defined $main::options{'s'});

		if ($main::configuration{'dbdriver'} eq "Pg") {
			$data_source = "DBI:$main::configuration{'dbdriver'}:dbname=$db";
			$data_source .= ";host=$hn" unless ($hn eq "");
		} elsif ($main::configuration{'dbdriver'} eq "Oracle") {
			$data_source = "DBI:$main::configuration{'dbdriver'}:$db";
			$data_source .= ";host=$hn;sid=$main::configuration{'oracle_sid'}" unless ($hn eq "");
			$data_source .= ";sid=$main::configuration{'oracle_sid'}";
		} elsif ($main::configuration{'dbdriver'} eq "Ingres") {
			$data_source = "DBI:$main::configuration{'dbdriver'}";
			$data_source .= ":$hn" unless ($hn eq "");
			$data_source .= ":$db";
		} elsif ($main::configuration{'dbdriver'} eq "Sybase") {
			$data_source = "DBI:$main::configuration{'dbdriver'}:$db";
			$data_source .= ";server=$hn" unless ($hn eq "");
		} elsif ($main::configuration{'dbdriver'} eq "ODBC") {
			if (!exists ($main::configuration{'odbc_driver'})) {
				$main::configuration{'odbc_driver'} = 'SQL Server';
			}
			if ($hn eq "") {
				$hn = 'localhost';
			}
			$data_source = "DBI:ODBC:Driver={$main::configuration{'odbc_driver'}};Server=$hn";
			$data_source .= ";Database=$db";
			$data_source .= ";UID=$un" unless ($un eq "");
			$data_source .= ";PWD=$pw" unless ($pw eq "");
		} else { # MySQL, mSQL, ...
			$data_source = "DBI:$main::configuration{'dbdriver'}:database=$db";
			$data_source .= ";host=$hn" unless ($hn eq "");
		}
	}
	if (!defined $main::options{'q'}) {
		my $msg = "Connect to database $db on ";
		$msg .= $hn || 'localhost';
		$msg .= " as user $un" unless ($un eq '');
		$msg .= " using a password" unless ($pw eq '');
		&print_message ($msg);
	}

	$main::db_handle = DBI->connect ($data_source, $un, $pw, { RaiseError => 0, PrintError => 1 }) || &just_died (1); # TODO Proper errorhandling
	return;
}

#####
# Check if the SQL statement contains options
# Supported options are:
#   setvar=<i>, where <i> is the list location to store the variable.
#   setarr=<i>
#
sub check_options ($) {
	my $options = shift;
	return if ($options eq '');
	$options =~ s/\[//;
	$options =~ s/\]//;

	my @optionlist = split /,/, $options;
	while (@optionlist) {
		my $opt = shift @optionlist;
		if ($opt =~ /^setvar=/i) {
			$main::var_no = $';
			$main::setvar = 1;
		}
		if ($opt =~ /^setarr=/i) {
			$main::arr_no = $';
			$main::setarr = 1;
		}
		if ($opt =~ /^fldsep=/i) {
			$main::fldsep = qq{$'};
			$main::fldsep =~ s/NEWLINE/\n/;
#			if ($main::fldsep eq 'NEWLINE') {
#				$main::fldsep = "\n";
#			}
		}
		if ($opt =~ /^rowsep=/i) {
			$main::rowsep = qq{$'};
			$main::rowsep =~ s/NEWLINE/\n/;
#			if ($main::rowsep eq 'NEWLINE') {
#				$main::rowsep = "\n";
#			}
		}
	}
}

#####
# Replace values from the query result as specified in the replace files.
# This is done in two steps, to prevent characters from being replaces again
# if they occus both as key and as value.
#
sub replace_values ($) {
	my $sqlresult = shift;
	my $rk;

	foreach $rk (@main::repl_order) {
		my ($begin, $end) = split /\Q$main::configuration{'rfile_regexploc'}\E/,$main::configuration{'rfile_regexp'};
		if ($rk =~ /^\Q$begin\E(.*)\Q$end\E$/) {
			$sqlresult =~ s/$1/$main::repl_key{$rk}/g;
		} else {
			$sqlresult =~ s/\Q$rk\E/$main::repl_key{$rk}/g;
		}
	}

	foreach $rk (keys %main::repl_key) {
		$sqlresult =~ s/$main::repl_key{$rk}/$main::repl_val{$main::repl_key{$rk}}/g;
	}
	return ($sqlresult);
}

#####
# Select multiple rows from the database. This function can have
# the [fldsep=s] and [rowsep=s] options to define the string which
# should be used to separate the fields and rows.
# By default, fields are separated with a comma and blank (', '), and rows
# are separated with a newline character ('\\')
#
sub sql_row ($$) {
	my ($options, $query) = @_;
	local $main::fldsep = ', ';
	local $main::rowsep = "\\\\";
	local $main::setarr = 0;	
	my (@values, @return_values, $rc, $fc);

	&check_options ($options);

	&print_message ("Retrieving row(s) with \"$query\"");
	$main::sql_statements++;
	my $stat_handle = $main::db_handle->prepare ($query);
	$stat_handle->execute ();

	if ($main::setarr) {
		&just_died (7) if (defined $main::arr[$main::arr_no] && !$main::multidoc); # TODO Proper errorhandling
		@main::arr[$main::arr_no] = ();
		while (my $ref = $stat_handle->fetchrow_hashref()) {
			foreach my $k (keys %$ref) {
				$ref->{$k}  = replace_values ($ref->{$k});
			}
			push @{$main::arr[$main::arr_no]},$ref;
		}
		$stat_handle->finish ();
		return ();
	}
	
	while (@values = $stat_handle->fetchrow_array ()) {
		$fc = $#values + 1;
		if (defined $main::replacefile) {
			my $list_cnt = 0;
			foreach (@values) {
				$values[$list_cnt] = replace_values ($values[$list_cnt]);
				$list_cnt++;
			}
		}
		push @return_values, (join "$main::fldsep", @values);
	}
	$stat_handle->finish ();

	if ($#return_values < 0) {
		&just_died (4); # TODO Proper errorhandling
	}

	$rc = $#return_values + 1;
	if ($rc == 1) {
		&print_message ("Found $rc row with $fc field(s)");
	} else {
		&print_message ("Found $rc rows with $fc fields each");
	}

	return (join "$main::rowsep", @return_values);

}


#####
# Select a single field from the database. This function can have
# the [setvar=n] option to define an internal variable
#
sub sql_field ($$) {
	my ($options, $query) = @_;
	local $main::setvar = 0;

	&check_options ($options);

	$main::sql_statements++;

	&print_message ("Retrieving field with \"$query\"");
	my $stat_handle = $main::db_handle->prepare ($query);
	$stat_handle->execute ();
	my @result = $stat_handle->fetchrow_array ();
	$stat_handle->finish ();

	if ($#result < 0) {
		&just_died (4); # TODO Proper errorhandling
	} elsif ($#result > 0) {
		&just_died (5); # TODO Proper errorhandling
	} else {
		&print_message ("Found 1 value: \"$result[0]\"");
		if ($main::setvar) {
			&just_died (7) if (defined $main::var[$main::var_no] && !$main::multidoc); # TODO Proper errorhandling
			$main::var[$main::var_no] = $result[0];
			return '';
		} else {
			if (defined $main::replacefile) {
				return (replace_values ($result[0]));
			} else {
				return ($result[0]);
			}
		}
	}
}

#####
# Start a section that will be repeated for evey row that is on stack
#
sub sql_start ($) {
	my $arr_no = shift;
	&just_died (11) if (!defined $main::arr[$arr_no]); # TODO Proper errorhandling
	if (@main::current_array) {
		@main::current_array = ();
	}
	@main::loop_data = ();
	push @main::current_array,$arr_no;
}

#####
# Use a named variable from the stack
#
sub sql_use ($$) {
	my ($field, $loop) = @_;
	return $main::arr[$#main::current_array][$loop]->{$field};
}


#####
# Stop processing the current array
#
sub sql_end () {
	my $result = '';

	for (my $cnt = 0; $cnt <= $#{$main::arr[$#main::current_array]}; $cnt++) {
		for (my $lines = 0; $lines < $#{$main::loop_data[$#main::current_array]}; $lines++) {
			my $buffered_line = ${$main::loop_data[$#main::current_array]}[$lines];
			my $cmdPrefix = $main::configuration{'alt_cmd_prefix'};
			while (($buffered_line  =~ /\\$cmdPrefix[a-z]+(\[|\{)/) && !($buffered_line  =~ /\\\\$cmdPrefix[a-z]+(\[|\{)/)) {
				my $cmdfound = $&;
				$cmdfound =~ s/\\//;
				$cmdfound =~ s/\{/\\\{/;

				$buffered_line  =~ /\\$cmdfound/;
				my $lin1 = $`;
				$buffered_line = $';
				$buffered_line =~ /\}/;
				my $statement = $`;
				my $lin2 = $';
			 	if ($cmdfound =~ /$main::configuration{'sql_use'}/) {
					$buffered_line = $lin1 . &sql_use($statement, $cnt) . $lin2;
				}
		 	}
		 	$result .= $buffered_line;
		}
	}
	
	pop @main::current_array;
	return $result;
}



#####
# Select a (list of) single field(s) from the database. This list is used in
# multidocument mode as the first parameter in all queries.
# Currently, only 1 parameter per run is supported.
#
sub sql_setparams ($$) {
	my ($options, $query) = @_;
	my (@values, @return_values, $rc);

	&check_options ($options);

	&print_message ("Retrieving parameter list with \"$query\"");
	$main::sql_statements++;
	my $stat_handle = $main::db_handle->prepare ($query);
	$stat_handle->execute ();

	while (@values = $stat_handle->fetchrow_array ()) {
		&just_died (9) if ($#values > 0); # Only one allowed TODO Proper errorhandling
		push @return_values, @values;
	}
	$stat_handle->finish ();

	if ($#return_values < 0) {
		&just_died (8); # TODO Proper errorhandling
	}

	$rc = $#return_values + 1;
	&print_message ("Multidocument parameters found; $rc documents will be created: handle document $main::multidoc_cnt");

	return (@return_values);
}


#####
# Perform an update.
#
sub sql_update ($$) {
	my ($options, $query) = @_;
	local $main::setvar = 0;

	if (!defined $main::options{'u'}) {
		&print_message ("Updates will be ignored");
		return;
	}
	&check_options ($options);

	&print_message ("Updating values with \"$query\"");
	my $rc = $main::db_handle->do($query);
	&print_message ("$rc rows updated");
}

##### 
# Some error handling (mainly cleanup stuff)
# Files will be closed if opened, and if no sql output was written yet,
# the outputfile will be removed.
# FIXME We need some decent errorhandling
#
sub just_died ($) {
	my $step = shift;
	my $Resurect = 0;

	$Resurect = 1 if ($step == 4 && $main::NULLallowed);

	if ($step >= 1 && !$Resurect) {
#		close FI;
#		close FO;
	}
	if ($step > 2 && !$Resurect) {
#		$main::db_handle->disconnect();
	}
	if ($step >= 1 && $step <= 2 && !$Resurect) {
		unlink ($main::outputfile);
	}

	#####
	# Step specific exit
	#
	my $msg;
	if ($step == 2) {
		$msg = "no database opened at line $main::lcount[$main::fcount]";
	} elsif ($step == 3) {
		$msg = "insufficient parameters to substitute variable on line $main::lcount[$main::fcount]";
	} elsif ($step == 4) {
		$msg = "no result set found on line $main::lcount[$main::fcount]";
	} elsif ($step == 5) {
		$msg = "result set too big on line $main::lcount[$main::fcount]";
	} elsif ($step == 6) {
		$msg = "trying to substitute with non existing on line $main::lcount[$main::fcount]";
	} elsif ($step == 7) {
		$msg = "trying to overwrite an existing variable on line $main::lcount[$main::fcount]";
	} elsif ($step == 8) {
		$msg = "no parameters for multidocument found on line $main::lcount[$main::fcount]";
	} elsif ($step == 9) {
		$msg = "too many fields returned in multidocument mode on $main::lcount[$main::fcount]";
	} elsif ($step == 10) {
		$msg = "unrecognized command on line $main::lcount[$main::fcount]";
	} elsif ($step == 11) {
		$msg = "start using a non-existing array on line $main::lcount[$main::fcount]";
	} elsif ($step == 12) {
		$msg = "\\sqluse command encountered outside loop context on line $main::lcount[$main::fcount]";
	}
	if ($main::fcount > 0) {
		for (my $fcnt = 0; $fcnt < $main::fcount; $fcnt++) {
			$msg .= ', file included from line '.$main::lcount[$fcnt];
		}
	}
	warn "$msg\n";
	return if ($Resurect);
	exit (1);
}

#####
# An SQL statement was found in the input file. If multiple lines are
# used for this query, they will be read until the '}' is found, after which
# the query will be executed.
#
sub parse_command ($$$) {
	my $cmdfound = shift;
	my $multidoc_par = shift;
	my $file_handle = shift;
	my $options = '';
	my $varallowed = 1;

	$varallowed = 0 if ($cmdfound =~ /$main::configuration{'sql_open'}/);

	chop $cmdfound;
	$cmdfound =~ s/\\//;

	$main::line =~ /\\$cmdfound/;
	my $lin1 = $`;
	$main::line = $';

	while (!($main::line =~ /\}/)) {
		chomp $main::line;
		$main::line .= ' ';
		$main::line .= <$file_handle>;
		$main::lcount[$main::fcount]++;
	}

	$main::line =~ /\}/;
	my $statement = $`;
	my $lin2 = $';

	$statement =~ s/(\[|\{)//g;
	if ($statement =~ /\]/) {
		$options = $`;
		$statement = $';
	}

	if ($varallowed) {
		if (($main::multidoc_cnt > 0) && $main::multidoc) {
			$statement =~ s/\$PAR1/$multidoc_par/g;
		} else {
			for (my $i = 1; $i <= $#ARGV; $i++) {
				$statement =~ s/\$PAR$i/$ARGV[$i]/g;
			}
		}
		while ($statement =~ /\$VAR[0-9]/) {
			my $varno = $&;
			$varno =~ s/\$VAR//;
			&just_died (6) if (!defined ($main::var[$varno])); # TODO Proper errorhandling
			$statement =~ s/\$VAR$varno/$main::var[$varno]/g;
		}
		&just_died (3) if ($statement =~ /\$PAR/ && ($main::multidoc_cnt > 0) && $main::multidoc); # TODO Proper errorhandling
		$statement =~ s/\{//;
	}

	if ($cmdfound =~ /$main::configuration{'sql_open'}/) {
		&db_connect($options, $statement);
		$main::db_opened = 1;
		return 0;
	}

	&just_died (2) if (!$main::db_opened); # TODO Proper errorhandling

	if ($cmdfound =~ /$main::configuration{'sql_field'}/) {
		$main::line = $lin1 . &sql_field($options, $statement) . $lin2;
	} elsif ($cmdfound =~ /$main::configuration{'sql_row'}/) {
		$main::line = $lin1 . &sql_row($options, $statement) . $lin2;
	} elsif ($cmdfound =~ /$main::configuration{'sql_params'}/) {
		if ($main::multidoc) { # Ignore otherwise
			@main::parameters = &sql_setparams($options, $statement);
			$main::line = $lin1 . $lin2;
			return 1; # Finish this run
		} else {
			$main::line = $lin1 . $lin2;
		}
	} elsif ($cmdfound =~ /$main::configuration{'sql_update'}/) {
		&sql_update($options, $statement);
		$main::line = $lin1 . $lin2;
	} elsif ($cmdfound =~ /$main::configuration{'sql_start'}/) {
		&sql_start($statement);
		$main::line = $lin1 . $lin2;
	} elsif ($cmdfound =~ /$main::configuration{'sql_use'}/) {
		&just_died (12) if (!@main::current_array); # TODO Proper errorhandling
		$main::line = $lin1 . "\\" . $main::configuration{'alt_cmd_prefix'} . $main::configuration{'sql_use'} . "{" . $statement . "}" . $lin2; # Restore the line, will be processed later
	} elsif ($cmdfound =~ /$main::configuration{'sql_end'}/) {
		$main::line = $lin1 . &sql_end() . $lin2;
	} else {
		&just_died (10); # TODO Proper errorhandling
	}

	return 0;
}

sub read_input($$$$) {
	my ($input_file, $output_handle, $multidoc_par) = @_;

	$main::fcount++;
	$main::lcount[$main::fcount] = 0;

	if (!-e $input_file) {
		die "input file $input_file not found";
	}
	print_message("Processing file $input_file...");
	open (my $fileIn,  "<$input_file");

	while ($main::line = <$fileIn>) {
		$main::lcount[$main::fcount]++;
		next if ($main::line =~ /^\s*%/);
		if ($main::line =~ /(.*?)(\\in(put|clude))(\s*?)\{(.*?)\}(.*)/) {
			print $output_handle "$1" unless ($output_handle == -1);
			&read_input($5, $output_handle, $multidoc_par);
			return if ($main::restart);
			print $output_handle "$6\n" unless ($output_handle == -1);
		}
		my $cmdPrefix = $main::configuration{'cmd_prefix'};
		while (($main::line =~ /\\$cmdPrefix[a-z]+(\[|\{)/) && !($main::line =~ /\\\\$cmdPrefix[a-z]+(\[|\{)/)) {
			if (&parse_command($&, $multidoc_par, $fileIn) && $main::multidoc && ($main::multidoc_cnt == 0)) {
				close $fileIn;
				$main::fcount--;
				$main::restart = 1;
				return;
			}
		}
		if (@main::current_array && $#main::current_array >= 0) {
			push @{$main::loop_data[$#main::current_array]}, $main::line;
		} else {	
			print $output_handle "$main::line" unless ($main::multidoc && ($main::multidoc_cnt == 0));
		}
	}
	$main::fcount--;
	close $fileIn;
}

#####
# Process the input file
# When multiple documents should be written, this routine is
# multiple times.
# The first time, it only builds a list with parameters that will be
# used for the next executions
#
sub process_file {
	my $multidoc_par = '';

	if ($main::multidoc && ($main::multidoc_cnt > 0)) {
		if (!defined($main::saved_outfile_template)) {
			$main::saved_outfile_template = $main::outputfile;
		}
		$main::saved_outfile_template = $main::outputfile if ($main::multidoc_cnt == 1); # New global name; should be a static
		$main::outputfile = $main::saved_outfile_template if ($main::multidoc_cnt > 1);
		$main::outputfile =~ s/\#M\#/$main::multidoc_cnt/;
		$main::outputfile =~ s/\#P\#/$main::parameters[($main::multidoc_cnt-1)]/;
		$multidoc_par = @main::parameters[$main::multidoc_cnt - 1];
	}
	my $fileOut;
	if ($main::multidoc && ($main::multidoc_cnt == 0)) {
		$fileOut = -1;
	} else {
		open ($fileOut, ">$main::outputfile");
	}

	$main::sql_statements = 0;
	$main::db_opened = 0;
	$main::fcount = -1;
	$main::restart = 0;

	&read_input($main::path . $main::inputfile, $fileOut, $multidoc_par);
	
	if ($main::multidoc) {
		$main::multidoc = 0 if (($main::multidoc_cnt++) > $#main::parameters);
		return if ($main::multidoc);
	}

	close $fileOut;
}

## Main:

#####
# Default config values, can be overwritten with SQLTeX.cfg
#
%main::configuration = (
	 'dbdriver'			=> 'mysql'
	,'oracle_sid'		=> 'ORASID'
	,'texex'			=> 'tex'
	,'stx'				=> '_stx'
	,'def_out_is_in'	=> 0
	,'rfile_comment'	=> ';'
	,'rfile_regexploc'	=> '...'
	,'rfile_regexp'		=> 're(...)'
	,'cmd_prefix'		=> 'sql'
	,'sql_open'			=> 'db'
	,'sql_field'		=> 'field'
	,'sql_row'			=> 'row'
	,'sql_params'		=> 'setparams'
	,'sql_update'		=> 'update'
	,'sql_start'		=> 'start'
	,'sql_end'			=> 'end'
	,'sql_use'			=> 'use'
	,'repl_step'		=> 'OSTX'
	,'alt_cmd_prefix' 	=> 'processedsqlcommand'
);

#####
# Some globals
#
{
	my @dir_list = split /\//, $0;
	pop @dir_list;
	$main::my_location = join '/', @dir_list;
	
	if (&is_linux) {
		$main::config_location = '{SYSCONFDIR}';
	} else {
		$main::config_location = $main::my_location;
	}
}

# Check config
# Used for loops, should not start with $main::configuration{'cmd_prefix'} !!
if ($main::configuration{'alt_cmd_prefix'} =~ /^$main::configuration{'cmd_prefix'}/) {
	die "Configuration item 'alt_cmd_prefix' cannot start with $main::configuration{'cmd_prefix'}";
}

$main::myself = $0;

$main::version = '2.1-1';
$main::rdate = 'Apr 19, 2022';

&parse_options;
if (defined $main::options{'l'}) {
	$main::config_location = $main::my_location;
}

&get_configfiles;

if (defined $main::configurationfile) {
	open (CF, "<$main::configurationfile");
	while ($main::line = <CF>) {
		next if ($main::line =~ /^\s*#/);
		next if ($main::line =~ /^\s*$/);
		chomp $main::line;
		my ($ck, $cv) = split /=/, $main::line, 2;
		$ck =~ s/\s//g;
		$cv =~ s/\s//g;
		if ($cv ne '') {
			$main::configuration{$ck} = $cv;
		}
	}
	close CF;
}

&get_filenames;

if (!$main::multidoc && -e "$main::outputfile") {
	die ("outputfile $main::outputfile already exists\n")
		unless (defined $main::options{'f'});
}

if (defined $main::replacefile) {
	my $repl_cnt = '000';
	@main::repl_order = ();
	open (RF, "<$main::replacefile");
	while ($main::line = <RF>) {
		next if ($main::line =~ /^\s*$main::configuration{'rfile_comment'}/);
		chomp $main::line;
		$main::line =~ s/\t+/\t/;
		my ($rk, $rv) = split /\t/, $main::line;
		if ($rk ne '') {
			push @main::repl_order, $rk;
			$main::repl_key{$rk} = "$main::configuration{'repl_step'}$repl_cnt";
			$main::repl_val{"$main::configuration{'repl_step'}$repl_cnt"} = $rv;
			$repl_cnt++;
		}
	}
	close RF;
}

# Start processing
do {
	&process_file;
	$main::restart = 0;
	if ($main::sql_statements == 0) {
		unlink ("$main::outputfile");
		print "no sql statements found in $main::path$main::inputfile\n";
		$main::multidoc = 0; # Problem in the input, useless to continue
	} else {
		print "$main::sql_statements queries executed - TeX file $main::outputfile written\n"
			unless ($main::multidoc && ($main::multidoc_cnt == 1));
	}
} while ($main::multidoc); # Set to false when done

$main::db_handle->disconnect() if ($main::db_opened);
exit (0);

#
# And that's about it.
#####
