#!/bin/bash

set -e
OLD_GW=`route | grep ^default | awk '{print $2}'`
sudo route del default gw $OLD_GW
PPP_ADDR=` ifconfig | grep ppp -A 1 | tail -n 1 | cut -d ':' -f 3 | cut -d ' ' -f 1`
sudo route add default gw $PPP_ADDR
