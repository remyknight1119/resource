#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 dir1 dir2 ..."
    exit 1
fi

FILE_DIR=$*

for file_dir in $FILE_DIR
do
    if [ ! -d $file_dir ]; then
        continue
    fi

    FILES=`find $file_dir`
    for file in $FILES
    do
        if [ -d $file ]; then
            continue
        fi
        md5sum $file
    done
done
