#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error!"
    exit 1
fi

UP_PKG=sys.tar.gz
if [ ! -f $UP_PKG ]; then
    echo "Error! Have no $UP_PKG!"
    exit 1
fi

IP_LIST=$1
UP_LOG=update.log
rm -f $UP_LOG
while read ip
do
    if [ `echo $ip | grep -c ^$` -ne 0 ]; then
        continue
    fi
    echo -n "Updating $ip ..."
    ping -c 3 $ip >/dev/null 
    if [ $? -ne 0 ]; then
        echo "Can't connect to $ip!"
        echo "Can't connect to $ip!" >> $UP_LOG
        continue
    fi
    wput $UP_PKG ftp://root:a8421m@$ip/update/
    if [ $? -eq 0 ]; then
        echo "OK!"
    else
        echo "Failed!"
        echo "Update $ip failed!" >> $UP_LOG
    fi
done < $IP_LIST
