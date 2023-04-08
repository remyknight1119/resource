#!/bin/bash

dir=`dirname $0`
#cd $dir

set -e
key_bits=2048
expire_days=3650
subj=/C="US"/ST="CA"/L="Sunnyvale"/O="Fortinet"/OU="Forti"/CN="testroot"
ca_name=ca-root
root_cacer=$ca_name.cer
root_cakey=$ca_name.key
#Root CA
openssl genrsa -out $root_cakey $key_bits
openssl req -x509 -newkey rsa:$key_bits -keyout $root_cakey -nodes -out $root_cacer -subj $subj -days $expire_days
echo "===================Gen Root CA OK===================="
