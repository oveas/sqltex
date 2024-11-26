#!/bin/bash
# Simple testscript to perform some SQLTeX regression tests
# This script requires a MySQL database. This database will be created with the sql file provided.

SQLTeXTop=$HOME/projects/sqltex
SQLTeXLocation=$SQLTeXTop/src
SQLTeXTestLocation=$SQLTeXTop/testSQLTeX
SQLTeXRefLocation=$SQLTeXTestLocation/reference

check_result() {
	echo -n "Compare sqltex-tc$1_$2.tex with the reference... ";
	diff -q $SQLTeXTestLocation/sqltex-tc$1_$2.tex $SQLTeXRefLocation/sqltex-tc$1_$2.tex > /dev/null
	if [ $? -eq 0 ]
	then
		STEST=$(($STEST+1))
		echo " Ok :)"
		rm $SQLTeXTestLocation/sqltex-tc$1_$2.tex
	else
		FTEST=$(($FTEST+1))
		echo " Failed :("
	fi
}

# Testcase 1: generate invoice
# This testcase handles basic functionality:
#  \sqlrow{}
#  \sqlfield{}
#  \sqlfield[setvar]{}
#  --filename-extend commandline options
#
testcase_1 () {
	echo ""
	echo " * Testcase 1: generate invoice number $1..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --username $USR --password $PWD --sqlserver $HST --quiet --null-allowed --filename-extend _{P1} sqltex-tc1 $1
	check_result 1 $1
}

# Testcase 2: loop function
# This testcase handles loop functionality:
#  \sqlrow[setarr]
#  \sqlstart{}
#  \sqlend{}
#  \sqluse[setvar]{}
#
testcase_2 () {
	echo ""
	echo " * Testcase 2: verify loop function..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet --update sqltex-tc2.tex
	check_result 2 stx
}

# Testcase 3: update function
# This testcase handles update functionality:
#  \sqlupdate{}
# This testcase relies on TC2 where the update is actually performed.
#
testcase_3 () {
	echo ""
	echo " * Testcase 3: verify update function..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet sqltex-tc3.tex
	check_result 3 stx
}

# Testcase 4: replacements
# This testcase handles the --replacementfile commandline options
#
testcase_4 () {
	echo ""
	echo " * Testcase 4: verify replacement function..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet --replace $SQLTeXTestLocation/sqltex-tc4_rpl.dat --filename-extend _nl1 sqltex-tc4.tex
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet --replace $SQLTeXTestLocation/sqltex-tc4_rpl.dat --no-default-replacefile --filename-extend _nl2 sqltex-tc4.tex
	check_result 4 nl1
	check_result 4 nl2
}

# Testcase 5: multi document
# This testcase handles the multidocument functionality
#  \sqlsetparams{}
#  --multidoc-numbered commandline option
#  --multidoc-named commandline option
testcase_5 () {
	echo ""
	echo " * Testcase 5a: verify multidoc (numbered) mode..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet --multidoc-numbered sqltex-tc5.tex
	check_result 5 stx_1
	check_result 5 stx_2
	check_result 5 stx_3
	check_result 5 stx_4
	check_result 5 stx_5
	check_result 5 stx_6
	echo ""
	echo " * Testcase 5b: verify multidoc (named) mode..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet --multidoc-named sqltex-tc5.tex
	check_result 5 stx_20190047
	check_result 5 stx_20190062
	check_result 5 stx_20190091
	check_result 5 stx_20190138
	check_result 5 stx_20190205
	check_result 5 stx_20190216
}

# Testcase 6: Upodate and multi document with parameters
# This testcase handles the multidocument functionality where the selection 
# statement needs parameters.
#  \sqlsetparams{}
#  \parse_command()
#  --multidoc-numbered commandline option
# This testcase relies on TC2 where an update was performed.
# 
testcase_6 () {
	echo ""
	echo " * Testcase 6: verify multidoc mode with parameters..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet --multidoc-numbered sqltex-tc6.tex 1 nr
	check_result 6 stx_1
	check_result 6 stx_2
	check_result 6 stx_3
}

# Testcase 7: replacements
# This testcase tests the use of parameters
#  \parse_command()
#
testcase_7 () {
	echo ""
	echo " * Testcase 7: verify parameters..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet sqltex-tc7.tex 10 price
	check_result 7 stx
}

# Testcase 8: if-endif construction and system callbacks
# This testcase handles conditional functionality:
#  \sqlif{condition}
#  \sqlendif{}
#  \sqlrow[setarr]
#  \sqlstart{}
#  \sqlend{}
#  \sqluse[setvar]{}
#  \sqlsystem{}
#
testcase_8 () {
	echo ""
	echo " * Testcase 8: verify if-endif condition block and system commands..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet sqltex-tc8.tex
	check_result 8 stx
}

# Testcase 9: Replacement file
# This testcase handles the text replacements using the replacement file
#
testcase_9 () {
	echo ""
	echo " * Testcase 9: verify replacement file..."
	perl $SQLTeXLocation/sqltex --configfile $SQLTeXLocation/SQLTeX.cfg --replacementfile $SQLTeXLocation/SQLTeX_r.dat --user $USR --password $PWD --sqlserver $HST --quiet sqltex-tc9.tex
	check_result 9 stx
}

CWD=`pwd`
STEST=0
FTEST=0
EXEC=0
if [ "$1" != "" ]
then
	EXEC=$1
fi

cd $SQLTeXTestLocation
echo -n "Database user: "
read USR

echo -n "Database password: "
ECHOLVL=`stty -g`
stty -echo
read PWD
stty $ECHOLVL
echo

read -p "Database server [localhost]: " HST
HST=${HST:-localhost}

echo "Creating the the test database..."
mysql --user=$USR --password=$PWD --host=$HST < testSQLTeX.sql

if [ $EXEC -eq 0 ] || [ $EXEC -eq 1 ]
then
	testcase_1 20190047
	testcase_1 20190062
	testcase_1 20190091
	testcase_1 20190138
	testcase_1 20190205
	testcase_1 20190216
fi

if [ $EXEC -eq 0 ] || [ $EXEC -eq 2 ]
then
	testcase_2
fi

if [ $EXEC -eq 0 ] || [ $EXEC -eq 3 ]
then
	testcase_3
fi

if [ $EXEC -eq 0 ] || [ $EXEC -eq 4 ]
then
	testcase_4
fi

if [ $EXEC -eq 0 ] || [ $EXEC -eq 5 ]
then
	testcase_5
fi

if [ $EXEC -eq 0 ] || [ $EXEC -eq 6 ]
then
	testcase_6
fi

if [ $EXEC -eq 0 ] || [ $EXEC -eq 7 ]
then
	testcase_7
fi

if [ $EXEC -eq 0 ] || [ $EXEC -eq 8 ]
then
	testcase_8
fi

if [ $EXEC -eq 0 ] || [ $EXEC -eq 9 ]
then
	testcase_9
fi

echo "Drop the test database..."
mysql --user=$USR --password=$PWD --host=$HST --execute='DROP SCHEMA `testsqltex`'

cd $CWD
echo ""
echo "  $STEST testcases succeeded"
echo "  $FTEST testcases failed"
echo "Done!"
