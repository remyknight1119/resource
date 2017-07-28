#!/bin/bash

if [ $# -ne 1 ] ; then
    echo "Please input user!";
    exit
fi

user=$1
dpkg-reconfigure wireshark-common
groupadd wireshark
chgrp wireshark /usr/bin/dumpcap
chmod 4755 /usr/bin/dumpcap
gpasswd -a $user wireshark
