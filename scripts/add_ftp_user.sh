#!/bin/bash

set -e

usage()
{
    echo "$0 [user] [password] [root_dir]"
}

if [ $# -ne 3 ]; then
    usage
    exit 1
fi
user_name=$1
password=$2
root_dir=$3
if [ -d $root_dir ]; then
    chmod 777 $root_dir
else
    base_dir=`dirname $root_dir`
    mkdir -p $base_dir
fi
no_login=`which nologin`
useradd -d $root_dir -s $no_login $user_name
echo "$user_name:$password" | chpasswd
