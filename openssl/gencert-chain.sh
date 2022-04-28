#!/bin/bash

dir=`dirname $0`
#cd $dir

set -e
key_bits=2048
expire_days=3650
subj=/C="CN"/ST="Liaoning"/L="Shenyang"/O="Dove"/OU="dove"/CN="doveR"
subji=/C="CN"/ST="Liaoning"/L="Shenyang"/O="Dove"/OU="dove"/CN="doveI"
subjs=/C="CN"/ST="Liaoning"/L="Shenyang"/O="Dove"/OU="dove"/CN="doveS"
subj2=/C="CN"/ST="Liaoning"/L="Shenyang"/O="DoveCERT"/OU="dove"/CN="dove"
server="server-chain"
param=$server
if [ -d $param ]; then
    rm -r $param
fi
mkdir -p $param
cd $param
ca_name=ca-root-$param
root_cacer=$ca_name.cer
root_cakey=$ca_name.key
ca_name=ca-sub1-$param
sub1_cacer=$ca_name.cer
sub1_cakey=$ca_name.key
ca_name=ca-sub2-$param
cacer=$ca_name.cer
cakey=$ca_name.key
cer=$param.cer
csr=$param.csr
key=$param.key

mkdir -p $dir/demoCA/{private,newcerts}
touch $dir/demoCA/index.txt
echo 02 > $dir/demoCA/serial
cd demoCA
ln -sf ../$root_cacer cacert.pem
cd -
cd demoCA/private
ln -sf ../../$root_cakey cakey.pem
cd -
ln -sf ../openssl.cnf
#Root CA
openssl genrsa -out $root_cakey $key_bits
openssl req -x509 -newkey rsa:$key_bits -keyout $root_cakey -nodes -out $root_cacer -subj $subj -days $expire_days
echo "===================Gen Root CA OK===================="

#Sub1 CA
openssl genrsa -out $sub1_cakey $key_bits
openssl req -new -key $sub1_cakey -sha256 -out $csr -subj $subji -days $expire_days
openssl ca -extensions v3_ca -batch -notext -in $csr -out $sub1_cacer -config ./openssl.cnf
echo "===================Gen Sub1 CA OK===================="

#Sub2 CA
openssl genrsa -out $cakey $key_bits
openssl req -new -key $cakey -sha256 -out $csr -subj $subjs -days $expire_days
openssl ca -extensions v3_ca -batch -notext -in $csr -out $cacer -cert $sub1_cacer -keyfile $sub1_cakey -config ./openssl.cnf

echo "===================Gen Sub2 CA OK===================="

#Server cert
openssl genrsa -out $key $key_bits
openssl req -new -key $key -sha256 -out $csr -subj $subj2 -days $expire_days
openssl x509 -req -in $csr -sha256 -out $cer -CA $cacer -CAkey $cakey -CAserial t_ssl_ca.srl -CAcreateserial -days $expire_days -extensions v3_req
cat $sub1_cacer $cacer $cer |tee $param.pem
openssl pkcs12 -export -clcerts -in $param.pem -inkey $key -out $param.p12
rm -f *.csr *.srl

#cat $sub1_cacer $cacer $cer $key |tee $param.pem
cat $cer $key $cacer $sub1_cacer |tee $param.pem
echo "===================Gen All OK===================="
# openssl verify -CAfile ca.cer client.cer

