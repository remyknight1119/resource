#!/bin/bash

if [ -f ./qemu-kvm ]; then
    . ./qemu-kvm
fi

if [ -z $ph_nic ]; then
	exit
fi

if [ x$host_ip = x ]; then 
	exit
fi

if [ -z $has_br ]; then
    sudo brctl addbr $switch 
fi

mask=`ifconfig $ph_nif | grep -w inet | awk '{print $4}' | cut -d ':' -f 2`
dfgw=`route | grep ^default | awk '{print $2}'`
sudo ifconfig $ph_nic 0.0.0.0
sudo ifconfig ${switch} $host_ip netmask $mask
sudo brctl addif ${switch} $ph_nic
sudo route add default gw $dfgw
