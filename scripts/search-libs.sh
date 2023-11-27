#!/bin/bash
 
# Set the root directory for the search
#root_directory="/path/to/your/directory"
dir=$1
target_lib=libcyprot.so.

if [ -z $dir ]; then
    dir=.
fi
 
libs=`find -L $dir -type f -name 'lib*.so*'`

for lib in $libs
do
    if [ -L $lib ]; then
        continue
    fi
    echo $lib
    if [ `objdump -p $lib | grep -w NEEDED | awk '{print $2}' | grep -c  $target_lib` -ne 0 ]; then
        echo "$lib depending on $target_lib"
    fi
done
