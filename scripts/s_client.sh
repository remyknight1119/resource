#!/bin/bash

addr=$1
port=$2
ca=$3

if [ $# -eq 0 ]; then
    echo "Usage: $0 addr port [ca]"
    exit 1
fi

cert="-cert /home/remy/test/rsa-single.pem"
cert="-cert client.cer"
cert_chain="-cert_chain chain.pem"
#cert=/home/remy/ocsp-cert/c/01.pem
#tls=-dtls
#tls=-tls1_1
#tls=-tls1
tls=-tls1_2
tls=-tls1_3
#sni="-servername domain1.net"
#sni="-servername remyknight1119.ml"
#sni="-servername fortinet-subca2001"
#sni="-servername dove"
#sni="-noservername"
#cipher="-ciphersuites ECDHE-RSA-CAMELLIA256-SHA384"
#ECDHE-ECDSA-CAMELLIA256-SHA384 ECDHE-RSA-CAMELLIA256-SHA384 DHE-RSA-CAMELLIA256-SHA256 ECDHE-ECDSA-CAMELLIA128-SHA256 ECDHE-RSA-CAMELLIA128-SHA256 DHE-RSA-CAMELLIA128-SHA256 DHE-RSA-CAMELLIA256-SHA
#cipher="-cipher ECDHE-ECDSA-RC4-SHA"
#cipher="-cipher RC4-SHA"
#cipher="-cipher ECDHE-RSA-AES128-GCM-SHA256"
#cipher="-cipher AES256-GCM-SHA384"
#cipher="-cipher DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384"
#cipher="-cipher ECDHE-RSA-AES256-SHA"
#cipher="-cipher ECDHE-ECDSA-AES256-GCM-SHA384"
#cipher="-cipher AES256-SHA"
#cipher="-cipher ECDHE-RSA-AES256-GCM-SHA384"
#cipher="-cipher ECDHE-ECDSA-AES128-SHA"
#sigalgs="-sigalgs ecdsa_secp521r1_sha512:ecdsa_secp384r1_sha384:ecdsa_secp256r1_sha256"
#groups="-groups ffdhe4096"
#groups="-groups ffdhe2048:ffdhe3072:x448"
#groups="-groups ffdhe2048:ffdhe3072:ffdhe4096:x448:secp256r1:secp521r1"
#groups="-groups x448:secp521r1:secp256r1"
#groups="-groups secp256r1"
ossl_cmd=~/openssl-openssl-3.0.6/apps/openssl
ossl_cmd=openssl

if [ -z $ca ]; then
    $ossl_cmd s_client -connect $addr:$port $sni $tls $cert $cert_chain -status -debug $cipher $sigalgs $groups
else
    $ossl_cmd s_client -connect $addr:$port $tls -verify 1 -CAfile $ca -verify_return_error
fi
