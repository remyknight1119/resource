#!/bin/bash

openssl req -out /root/TFTP/cert_test/ecdsa_ca_req.pem -newkey rsa:2048 -keyout /root/TFTP/cert_test/ecdsa_ca_key.pem -subj /C=US/ST=CA/L=CA/O=Test/OU=FortiADC/CN=ecdsa_ca.pem -passout pass:fortinet -days 365
cd /root/TFTP/cert_test
openssl ca -config /root/TFTP/cert_test/openssl.cnf -create_serial -out /root/TFTP/cert_test/ecdsa_ca.pem -days 1095 -batch -keyfile /root/TFTP/cert_test/ecdsa_ca_key.pem -keyform PEM -key fortinet -selfsign -extensions v3_ca -infiles /root/TFTP/cert_test/ecdsa_ca_req.pem
openssl x509 -in /root/TFTP/cert_test/ecdsa_ca.pem -outform PEM -out /root/TFTP/cert_test/ecdsa_ca.pem

