#!/bin/bash

subj=/C="US"/ST="CA"/L="ECDSA2"/O="Test"/OU="ecdsa"/CN="domain1.net"
target_cert=ecdsa-ocsp.cer
target_key=ecdsa-ocsp.key
target_req=ecdsa-ocsp.req
ec_key=ecdsa.keyfile
openssl ecparam -name prime256v1 -genkey -out $ec_key
openssl req -out /root/TFTP/cert_test/$target_req -newkey ec:$ec_key -keyout /root/TFTP/cert_test/$target_key -subj $subj -passout pass:fortinet -days 365
openssl ca -config /root/TFTP/cert_test/openssl.cnf -policy policy_anything -out /root/TFTP/cert_test/$target_cert -batch -keyfile /root/TFTP/cert_test/ecdsa_ca_key.pem -keyform PEM -key fortinet -cert /root/TFTP/cert_test/ecdsa_ca.pem -infiles /root/TFTP/cert_test/$target_req
openssl x509 -in /root/TFTP/cert_test/$target_cert -outform PEM -out /root/TFTP/cert_test/$target_cert
