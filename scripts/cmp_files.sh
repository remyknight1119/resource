#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 src_dir dst_dir"
    exit 1
fi
SDIR=$1
DDIR=$2

if [ `echo $SDIR | grep ^/ -c` -ne 1 ]; then
    SDIR=$PWD/$SDIR
fi

cd $SDIR
SFILES=`find .`
cd -
cd $DDIR

for sfile in $SFILES
do
    if [ $sfile = '.' ]; then
        continue;
    fi
    if [ ! -f $sfile ]; then
        echo "$sfile not exist in $DDIR!"
        continue;
    fi
    smd5=`md5sum $SDIR/$sfile | awk '{print $1}'`
    dmd5=`md5sum $sfile | awk '{print $1}'`
    if [ $smd5 != $dmd5 ]; then
        echo "$sfile not same"
    fi
done
