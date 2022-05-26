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
cacer=$ca_name.cer
cakey=$ca_name.key
ca_name1=ca-sub1-$param
sub1_cacer=$ca_name1.cer
sub1_cakey=$ca_name1.key
ca_name2=ca-sub2-$param
sub2_cacer=$ca_name2.cer
sub2_cakey=$ca_name2.key
cer=$param.cer
csr=$param.csr
key=$param.key
ca_chain=$param-ca-chain.cer

mkdir -p $dir/demoCA/{private,newcerts}
touch $dir/demoCA/index.txt
echo 02 > $dir/demoCA/serial
cd demoCA
ln -sf ../$cacer cacert.pem
cd -
cd demoCA/private
ln -sf ../../$cakey cakey.pem
cd -
ln -sf ../openssl.cnf
#Root CA
openssl genrsa -out $cakey $key_bits
openssl req -x509 -newkey rsa:$key_bits -keyout $cakey -nodes -out $cacer -subj $subj -days $expire_days
echo "===================Gen Root CA OK===================="

#Sub1 CA
openssl genrsa -out $sub1_cakey $key_bits
openssl req -new -key $sub1_cakey -sha256 -out $csr -subj $subji
openssl ca -extensions v3_ca -batch -notext -days $expire_days -in $csr -out $sub1_cacer -config ./openssl.cnf
echo "===================Gen Sub1 CA OK===================="

#Sub2 CA
openssl genrsa -out $sub2_cakey $key_bits
openssl req -new -key $sub2_cakey -sha256 -out $csr -subj $subjs
openssl ca -extensions v3_ca -batch -notext -days $expire_days -in $csr -out $sub2_cacer -cert $sub1_cacer -keyfile $sub1_cakey -config ./openssl.cnf

echo "===================Gen Sub2 CA OK===================="

#Server cert
openssl genrsa -out $key $key_bits
openssl req -new -key $key -sha256 -out $csr -subj $subj2 -days $expire_days
openssl x509 -req -in $csr -sha256 -out $cer -CA $sub2_cacer -CAkey $sub2_cakey -CAserial t_ssl_ca.srl -CAcreateserial -days $expire_days -extensions v3_req
cat $sub1_cacer $cacer $cer |tee $param.pem
openssl pkcs12 -export -clcerts -in $param.pem -inkey $key -out $param.p12
rm -f *.csr *.srl

#cat $sub1_cacer $cacer $cer $key |tee $param.pem
cat $cer $key $sub1_cacer $sub2_cacer | tee $param.pem
cat $cacer $sub1_cacer $sub2_cacer | tee $ca_chain
echo "===================Gen All OK===================="
openssl verify -CAfile $ca_chain $cer
#openssl verify -verify_depth 6 -CAfile $cacer $param.pem

