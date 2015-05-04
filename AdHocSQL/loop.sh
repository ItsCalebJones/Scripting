#!/bin/sh

a=0

while [ $a -le 999 ]
do
	echo "Execution number $a"
	echo
	perl testsih.pl -i 10.64.4.124 -u cjones -p cjones -r 2
    ((a++))
done