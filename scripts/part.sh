#!/bin/bash

usage() 
{
	echo "Usage: $0 size(example: 80M) dev(example: /dev/sdb)"
}

if [ $# -ne 2 ]; then
	usage
	exit 1
fi

set -e
size=$1
dev=$2
num=`fdisk -l $dev | grep ^\/dev -c`
while [ $num -gt 0 ]
do
	parted -s $dev rm $num
	num=$((num - 1))
done
parted -s $dev mkpart primary 1 $size
parted -s $dev mkpart primary $size 100%


mkfs -t vfat ${dev}1
mkfs -t ext3 ${dev}2

