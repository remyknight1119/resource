#!/bin/bash

sudo service ipsec restart
sleep 1
sudo /usr/sbin/ipsec whack --name roadwarrior --initiate
