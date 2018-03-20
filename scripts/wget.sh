#!/bin/bash

file=test
ip=10.0.5.116
ip=192.168.135.6
port=8080
proto=http
port=447
proto=https
while :
do
    rm $file*
    #wget $proto://$ip:$port/$file --no-check-certificate --tries=1 --secure-protocol=TLSv1
    wget $proto://$ip:$port/$file --no-check-certificate --tries=1 --secure-protocol=TLSv1_2
    #wget $proto://$ip:$port/$file
    if [ $? -ne 0 ]; then
        echo "Error!"
        break
    fi
    break
done
