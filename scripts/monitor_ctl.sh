#!/bin/bash

set -e

usage()
{
    echo "usage: $0 -a [start|stop] -c [test_conf]"
}

while getopts ":a:c:" Option
do
    case $Option in
        a)
            ACTION=$OPTARG
            ;;
        c)
            CONFIG=$OPTARG
            ;;
    esac
done

if [ 'x' = x$ACTION ]; then
    echo "please input action -a"
    usage
    exit 1
fi

action="-a $ACTION"
if [ $ACTION = "start" ]; then
    if [ 'x' = x$CONFIG ]; then
        echo "please input test_conf -c"
        usage
        exit 1
    fi
    action="$action -c $CONFIG"
fi

if [ `ps -fp $$ | tail -n 1 | awk '{print $1}' | grep -c ^root` -ne 1 ]; then
    echo "Please use $0 by root or sudo!";
    exit 1
fi

ppid=`ps -fp $$ | awk '{print $3}' | tail -n 1`
pppid=`ps -fp $ppid | awk '{print $3}' | tail -n 1`
pppuser=`ps -fp $pppid | awk '{print $1}' | tail -n 1`

if [ $pppuser = 'root' ]; then
    confdir=/root/.senginx-test
else
    confdir=/home/$pppuser/.senginx-test
fi

auto_monitor.pl $action -m $confdir
