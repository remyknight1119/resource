#!/bin/sh

rm -f *.log
bin=httproxy-ssl
ftpget 172.30.154.251 $bin
cp $bin /bin/
chmod 755 /bin/$bin
md5sum /bin/$bin
killall $bin

