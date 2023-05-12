#!/bin/bash

dir=`dirname $0`
#cd $dir

set -e
key_bits=2048
expire_days=3650
subj=/C="US"/ST="CA"/L="RSA1"/O="Fortinet"/OU="ecdsa"/CN="domain3.net"
ca_name=ca-root
root_cacer=$ca_name.cer
root_cakey=$ca_name.key
cacer=$ca_name.cer
cakey=$ca_name.key
param=ecdsa-single
cer=$param.cer
csr=$param.csr
key=$param.key

if [ ! -d $dir/demoCA ]; then
    mkdir -p $dir/demoCA/{private,newcerts}
    touch $dir/demoCA/index.txt
    echo 02 > $dir/demoCA/serial
fi
cd demoCA
ln -sf ../$root_cacer cacert.pem
cd -
cd demoCA/private
ln -sf ../../$root_cakey cakey.pem
cd -

#Server cert
openssl ecparam -name prime256v1 -genkey -out $key
openssl req -new -key $key -sha256 -out $csr -subj $subj -days $expire_days
openssl x509 -req -in $csr -sha256 -extfile ./openssl.cnf -out $cer -CA $cacer -CAkey $cakey -CAserial t_ssl_ca.srl -CAcreateserial -days $expire_days -extensions v3_req
#openssl pkcs12 -export -clcerts -in client.cer -inkey client.key -out client.p12
rm -f *.csr *.srl

#cat $sub1_cacer $cacer $cer $key |tee $param.pem
cat $cer $key | tee $param.pem
echo "===================Gen All OK===================="
# openssl verify -CAfile ca.cer client.cer

