#!/bin/bash

usage()
{
    echo "$0 [user]"
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi
user_name=$1
userdel $user_name
