#!/bin/bash

host=10.106.133.7
host=10.106.133.5
host=10.106.133.8
host=10.106.153.8
port=447
port=448
port=449

file=index_1bytes.html
file=i.txt
file=60M
file=2M

tls_version="--tlsv1.3"
ciphers="--cipher ECDHE-ECDSA-AES128-SHA256:AES256-GCM-SHA384"
http2=--http2
http2=
servername=example.com
sni="--resolve $servername:$port:$host"
#test_dir=data
#cd $test_dir
#rm -f *

count=1
while [ $count -gt 0 ]
do
    #wget https://$host:$port/$file --no-check-certificate --secure-protocol=TLSv1_2 -t 1 &
    curl -k -v $sni $http2 $ciphers $tls_version https://$servername:$port/$file
    count=$((count - 1))
done
