#!/bin/bash

up_dir=/update
up_log=/home/root/.update.log
backup_dir=$up_dir/backup
sys_tar=$up_dir/sys.tar.gz
mkdir -p $up_dir
while :
do
    sleep 1
    if [ ! -f $sys_tar ]; then
        continue
    fi
    #文件大小不变时即文件上传完毕
    last_size=`ls -l $sys_tar | awk '{print $5}'`
    while :
    do
        sleep 1
        curr_size=`ls -l $sys_tar | awk '{print $5}'`
        if [ $last_size -eq $curr_size ]; then
            break
        fi
        last_size=$curr_size
    done
    up_files=`tar tzf $sys_tar`
    #备份要升级的文件
    for uf in $up_files
    do
        if [ -f /$uf ]; then
            dir=`dirname $uf`
            mkdir -p $backup_dir/$dir
            mv $uf $backup_dir/$dir
        fi
    done

    tar xvzf $sys_tar -C /
    rm -f $sys_tar
    TIME=`date`
    echo "Update time: $TIME">> $up_log
    reboot
done
