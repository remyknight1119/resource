#!/bin/bash

set -e

usage()
{
    echo "$0 iso_src_dir iso_output_dir iso_name"
}

ISO_SRC_DIR=$1
ISO_OUTPUT=$2
ISO_NAME=$3

if [ $# -ne 3 ]; then
    usage
    exit 1
fi

mkdir -p $ISO_OUTPUT

if [ `echo $ISO_OUTPUT | grep -c ^/` -eq 0 ]; then
    ISO_OUTPUT=${PWD}/$ISO_OUTPUT
fi

cd $ISO_SRC_DIR
createrepo -g repodata/*comps.xml .
echo 'createrepo success!'
ISO_FILE=${ISO_NAME}.iso
mkisofs -R -T -r -l -d -allow-multidot -allow-leading-dots -no-bak -o $ISO_OUTPUT/$ISO_FILE -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table . 
