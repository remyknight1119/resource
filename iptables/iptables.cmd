#Drop
iptables -A FORWARD -s 192.168.145.12 -p tcp --destination-port 443 -j DROP

#SNAT
iptables -t nat -A POSTROUTING -s 10.106.153.20/32 -o ens160 -j SNAT --to-source 1.1.1.112 --destination 10.106.153.19
