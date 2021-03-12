#!/bin/bash

dir=`dirname $0`
#cd $dir

set -e
dst_dir=`dirname $1`
expire_days=3650
ca_name=ca-root
root_cacer=$ca_name.cer
root_cakey=$ca_name.key
param=cert
cacer=$ca_name.cer
cakey=$ca_name.key
cnf=/etc/pki/tls/openssl.cnf
cnf=./osan.cnf

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

csr=$1
cer=$csr.cer
#Server cert
#openssl x509 -req -in $csr -sha256 -extfile $cnf -out $cer -CA $cacer -CAkey $cakey -CAserial t_ssl_ca.srl -CAcreateserial -days $expire_days -extensions v3_req
openssl ca -config $cnf -name CA_default -policy policy_anything -cert $cacer -keyfile $cakey -in $csr -out $cer -outdir .

echo "===================Gen $cer OK===================="
rm $csr

