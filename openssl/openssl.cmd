openssl genrsa -out private_rsa.pem 2048
openssl genrsa -aes128 -passout pass:123456 -out $key_file $key_bits
openssl req -new -x509 -key private_rsa.pem -out cacert.pem -days 1095
openssl rsa -in private_rsa.pem -pubout -out public_rsa.pem
openssl rsautl -encrypt -in a.txt -inkey private_rsa.pem -out a.enc 
openssl rsautl -decrypt -in a.enc -pubin -inkey public_rsa.pem 
openssl rsautl -decrypt -in a.enc -inkey public_rsa.pem -pubin
openssl rsautl -sign -inkey private_rsa.pem -in a.txt  -out  sig.dat
openssl rsautl -verify -inkey private_rsa.pem -in  sig.dat
openssl rsautl -verify -pubin -inkey public_rsa.pem -in sig.dat
openssl rsa -inform PEM -in test/pub_key.pem -pubin -text
#show X509 cert
openssl x509 -noout -text -in test/pem/cacert.pem
openssl dsa -in client.key -text -out private.txt
#show ECDSA key
openssl ec -in ecdsa.key -text
#pfx to pem
openssl pkcs12 -in rsa-single.pfx -nodes -out test.pem
#show CSR
openssl req -noout -text -in my.csr
#verify CA and cert
openssl verify -verbose -CAfile ca-root.cer rsa-single.cer

2 创建CA根级证书
生成key：openssl genrsa -out /etc/pki/ca_linvo/root/ca.key
生成csr：openssl req -new -key /etc/pki/ca_linvo/root/ca.key -out /etc/pki/ca_linvo/root/ca.csr
生成crt：openssl x509 -req -days 3650 -in /etc/pki/ca_linvo/root/ca.csr -signkey /etc/pki/ca_linvo/root/ca.key -out /etc/pki/ca_linvo/root/ca.crt
生成crl：openssl ca -gencrl -out /etc/pki/ca_linvo/root/ca.crl -crldays 7

#To convert a PEM certificate to a DER certificate
openssl x509 -inform pem -in Certificate.pem -outform der -out Certificate.der
#To convert a PEM private key to a DER private key
openssl rsa -inform pem -in PrivateKey.pem -outform der -out PrivateKey.der
openssl ec -inform pem -in ecdsa-single.pem -outform der -out ecdsa-single.der
#Extract public key
openssl pkey -inform PEM -outform PEM -in rsa-single.pem -pubout -out rsa-single-pub.pem
