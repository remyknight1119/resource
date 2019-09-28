openssl genrsa -out private_rsa.pem 2048
openssl req -new -x509 -key private_rsa.pem -out cacert.pem -days 1095
openssl rsa -in private_rsa.pem -pubout -out public_rsa.pem
openssl rsautl -encrypt -in a.txt -inkey private_rsa.pem -out a.enc 
openssl rsautl -decrypt -in a.enc -pubin -inkey public_rsa.pem 
openssl rsautl -decrypt -in a.enc -inkey public_rsa.pem -pubin
openssl rsautl -sign -inkey private_rsa.pem -in a.txt  -out  sig.dat
openssl rsautl -verify -inkey private_rsa.pem -in  sig.dat
openssl rsautl -verify -pubin -inkey public_rsa.pem -in sig.dat
openssl rsa -inform PEM -in test/pub_key.pem -pubin -text
openssl x509 -noout -text -in test/pem/cacert.pem
openssl dsa -in client.key -text -out private.txt
#pfx to pem
openssl pkcs12 -in rsa-single.pfx -nodes -out test.pem
openssl req -in my.csr -noout -text

2 创建CA根级证书
生成key：openssl genrsa -out /etc/pki/ca_linvo/root/ca.key
生成csr：openssl req -new -key /etc/pki/ca_linvo/root/ca.key -out /etc/pki/ca_linvo/root/ca.csr
生成crt：openssl x509 -req -days 3650 -in /etc/pki/ca_linvo/root/ca.csr -signkey /etc/pki/ca_linvo/root/ca.key -out /etc/pki/ca_linvo/root/ca.crt
生成crl：openssl ca -gencrl -out /etc/pki/ca_linvo/root/ca.crl -crldays 7
