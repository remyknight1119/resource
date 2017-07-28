#!/bin/sh

MIN_FREE=500000

while [ 1 ]
do
	FREE_MEM=`free | grep Mem | awk '{print $4}'`
#	echo $FREE_MEM

	if [ $FREE_MEM -lt $MIN_FREE ]; then
		sync
		echo 1 > /proc/sys/vm/drop_caches
	fi
	sleep 10
done

