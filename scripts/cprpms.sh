#!/bin/bash 

set -e

usage()
{
    echo "$0 src dst packages_list"
}

SRC=$1 
DST=$2
packages_list=$3

if [ $# -ne 3 ]; then
    usage
    exit 1
fi

while read name 
do 
    echo "cp $SRC/$name* $DST/" 
    cp $SRC/$name* $DST/ 
    # in case the copy failed 
    if [ $? -ne 0 ] ; then 
        echo "cp $SRC/$name failed " 
    fi 

done < $packages_list 
