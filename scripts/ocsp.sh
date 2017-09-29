#!/bin/bash

openssl ocsp -index /root/TFTP/cert_test/CA/index.txt -CA /root/TFTP/cert_test/myca.pem -port 8888 -rsigner /root/TFTP/cert_test/myca.pem -rkey /root/TFTP/cert_test/myca_key.pem.plain -ndays 365
