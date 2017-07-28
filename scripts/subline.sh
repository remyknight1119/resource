#!/bin/bash

str="use lib '../lib';"
files=`ls *.t`
for f in $files
do
    sed -i /"^use lib"/d $f
    line=`grep use $f -n | head -n 1 | cut -d ':' -f 1`
    sed -i "$line a $str" $f
done
