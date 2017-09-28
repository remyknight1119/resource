#!/bin/bash

dir=`dirname $0`
#cd $dir

set -e
key_bits=2048
expire_days=3650
subj=/C="CN"/ST="Beijing"/L="Haidian"/O="Fortinet"/OU="Forti"/CN="testroot"
rm -rf $dir/demoCA 
mkdir -p $dir/demoCA/{private,newcerts}
touch $dir/demoCA/index.txt
echo 00 > $dir/demoCA/serial

ca_name=ca-root
root_cacer=$ca_name.cer
root_cakey=$ca_name.key
root_csr=$ca_name.csr
#Root CA
openssl genrsa -out $root_cakey $key_bits
openssl req -new -key $root_cakey -out $root_csr -subj $subj -days $expire_days
openssl ca -keyfile $root_cakey -out $root_cacer -infiles $root_csr -selfsign
echo "===================Gen Root CA OK===================="
