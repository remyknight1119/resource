#!/bin/bash

program_name=${0##*/}

num=`ps au | grep $1 -m 1 | sed '/'$program_name'/d' | awk '{print $2}'`

if [ -z $num ]; then
	echo "Process not found: $1"
	exit
fi

name=`ps au | grep $1 -m 1 | sed '/'$program_name'/d' | cut -c 66-`
echo "Matching: '$name'"

kill -9 $num

if [ $? -eq 0 ]; then
	echo "Killed."
else
	echo "Failed to kill."
fi
