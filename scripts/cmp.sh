#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 src_md5 dst_md5"
    exit 1
fi

SRC_MD5=$1
DST_MD5=$2

files=`awk '{print $2}' $SRC_MD5 | grep -v ^$`
for file in $files
do
    if [ `grep -c $file$ $DST_MD5` -eq 0 ]; then
        echo "$file is more"
    else
        smd5=`grep -w $file$ $SRC_MD5 | head -n 1 | awk '{print $1}'`
        dmd5=`grep -w $file$ $DST_MD5 | head -n 1 | awk '{print $1}'`
        if [ `grep -w $file$ $DST_MD5 | awk '{print $1}' | wc -l` -gt 1 ]; then
            echo "$file is more than 1"
        fi
        if [ $smd5 != $dmd5 ]; then
            echo "##########################$file is different!"
        fi
    fi
done
