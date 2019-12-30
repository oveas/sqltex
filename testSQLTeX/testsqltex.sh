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
	perl $SQLTeXLocation/SQLTeX.pl --username $USR --password $PWD --quiet --null-allowed --filename-extend _{P1} sqltex-tc1 $1
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
	perl $SQLTeXLocation/SQLTeX.pl --user $USR --password $PWD --quiet --update sqltex-tc2.tex
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
	perl $SQLTeXLocation/SQLTeX.pl --user $USR --password $PWD --quiet sqltex-tc3.tex
	check_result 3 stx
}

# Testcase 4: replacements
# This testcase handles the --replacementfile commandline options
#
testcase_4 () {
	echo ""
	echo " * Testcase 4: verify loop function..."
	perl $SQLTeXLocation/SQLTeX.pl --user $USR --password $PWD --quiet --replace $SQLTeXTestLocation/sqltex-tc4_rpl.dat --filename-extend _nl sqltex-tc4.tex
	check_result 4 nl
}

# Testcase 5: multi document
# This testcase handles the multidocument functionality
#  \sqlsetparams{}
#  --multidoc-numbered commandline option
#  --multidoc-named commandline option
testcase_5 () {
	echo ""
	echo " * Testcase 5a: verify multidoc (numbered) mode..."
	perl $SQLTeXLocation/SQLTeX.pl --user $USR --password $PWD --quiet --multidoc-numbered sqltex-tc5.tex
	check_result 5 stx_1
	check_result 5 stx_2
	check_result 5 stx_3
	check_result 5 stx_4
	check_result 5 stx_5
	check_result 5 stx_6
	echo ""
	echo " * Testcase 5b: verify multidoc (named) mode..."
	perl $SQLTeXLocation/SQLTeX.pl --user $USR --password $PWD --quiet --multidoc-named sqltex-tc5.tex
	check_result 5 stx_20190047
	check_result 5 stx_20190062
	check_result 5 stx_20190091
	check_result 5 stx_20190138
	check_result 5 stx_20190205
	check_result 5 stx_20190216
}

CWD=`pwd`
STEST=0
FTEST=0

cd $SQLTeXTestLocation
echo -n "Database user: "
read USR

echo -n "Database password: "
ECHOLVL=`stty -g`
stty -echo
read PWD
stty $ECHOLVL
echo

echo "Creating the the test database..."
mysql --user=$USR --password=$PWD < testSQLTeX.sql

testcase_1 20190047
testcase_1 20190062
testcase_1 20190091
testcase_1 20190138
testcase_1 20190205
testcase_1 20190216

testcase_2

testcase_3

testcase_4

testcase_5

echo "Drop the test database..."
mysql --user=$USR --password=$PWD --execute='DROP SCHEMA `testsqltex`'

cd $CWD
echo ""
echo "  $STEST testcases succeeded"
echo "  $FTEST testcases failed"
echo "Done!"
