#!/bin/bash

#dir=`dirname $0`
#cd $dir

set -e
key_bits=2048
expire_days=3650
subj=/C="CN"/ST="Liaoning"/L="Shenyang"/O="Dove"/OU="dove"/CN="dove"
subj2=/C="CN"/ST="Liaoning"/L="Shenyang"/O="DoveCERT"/OU="dove"/CN="dove"
usage()
{
    echo "$0 client|server|package"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi
client="client"
server="server"
clientkeys="client-keys"
serverkeys="server-keys"
param=$1
if [ $param != $client -a $param != $server ]; then
    if [ $param = "package" ]; then
        rm -rf $clientkeys $serverkeys
        mkdir $clientkeys $serverkeys
        cp $client/* $clientkeys
        rm -f $clientkeys/ca-*
        cp $server/ca-*.cer $clientkeys/ca.cer
        cp $server/* $serverkeys
        rm -f $serverkeys/ca-*
        cp $client/ca-*.cer $serverkeys/ca.cer
        exit 0
    else
        usage
        exit 1
    fi
fi
mkdir -p $param
cd $param
cacer=ca-$param.cer
cakey=ca-$param.key
cer=$param.cer
csr=$param.csr
key=$param.key
if [ ! -f $cacer ]; then
#Root
openssl genrsa -out $cakey $key_bits
openssl req -x509 -newkey rsa:$key_bits -keyout $cakey -nodes -out $cacer -subj $subj -days $expire_days
fi
openssl genrsa -out $key $key_bits
openssl req -new -key $key -sha256 -out $csr -subj $subj2 -days $expire_days
openssl x509 -req -in $csr -sha256 -out $cer -CA $cacer -CAkey $cakey -CAserial t_ssl_ca.srl -CAcreateserial -days $expire_days -extensions v3_req
#openssl pkcs12 -export -clcerts -in client.cer -inkey client.key -out client.p12
rm -f *.csr *.srl

# openssl verify -CAfile ca.cer client.cer
