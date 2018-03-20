#!/bin/bash

if [ $# -eq 0 ];then
    echo "$0 file"
    exit 1
fi

if [ -z $2 ]; then
    wput $1 ftp://172.30.154.251/Remy/
else
    wput $1 ftp://172.30.154.251/
fi
