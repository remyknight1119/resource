#!/bin/bash

subj=/C="CN"/ST="Beijing"/L="RSA1"/O="Fortinet"/OU="rsa"/CN="domain1.net"
target_cert=rsa-ocsp.cer
target_key=rsa-ocsp.key
target_req=rsa-ocsp.req
openssl req -out /root/TFTP/cert_test/$target_req -newkey rsa:2048 -keyout /root/TFTP/cert_test/$target_key -subj $subj -passout pass:fortinet -days 365
openssl ca -config /root/TFTP/cert_test/openssl.cnf -policy policy_anything -out /root/TFTP/cert_test/$target_cert -batch -keyfile /root/TFTP/cert_test/myca_key.pem -keyform PEM -key fortinet -cert /root/TFTP/cert_test/myca.pem -infiles /root/TFTP/cert_test/$target_req
openssl x509 -in /root/TFTP/cert_test/$target_cert -outform PEM -out /root/TFTP/cert_test/$target_cert
