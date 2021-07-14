#!/bin/bash

priv=vmmon.priv
der=vmmon.der
openssl req -new -x509 -newkey rsa:2048 -keyout $priv -outform DER -out $der -nodes -days 36500 -subj "/CN=VMware/"
sudo /usr/src/linux-headers-`uname -r`/scripts/sign-file sha256 $priv $der $(modinfo -n vmmon)
sudo /usr/src/linux-headers-`uname -r`/scripts/sign-file sha256 $priv $der $(modinfo -n vmnet)
sudo mokutil --import $der
