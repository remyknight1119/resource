#!/usr/bin/env python
# -*- coding:utf-8 -*-
#此脚本每隔一定时间检查主机的IP地址是否有变化，如果变化，则更改到原来的地址

import commands,os,time

INTERVAL = 10

while True:
	res=commands.getoutput("ifconfig eth21")		#change me
	res1=res.split()
	res2=res1[6]
	ipaddr=res2.split(":")[1]

	if (cmp(ipaddr,"10.2.2.177")!=0):		# change me
		os.system("ifconfig eth2 10.2.2.177/21")	# change me
	
	route=commands.getoutput("route -n").split()
	default=route[-8]
	if (cmp(default,"0.0.0.0")!=0):
		os.system("route add default gw 10.2.2.1")	#change me

	time.sleep(INTERVAL)

