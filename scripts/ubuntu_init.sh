#!/bin/bash

deploy_scripts()
{
    cd $1
    sudo cp -f cdata.sh /sbin/
    user=`ps -fp $$ | tail -n 1 | awk '{print $1}'`
    echo "user: $user"
    sudo ./wireshark-ubuntu.sh $user
    cd -
}

change_conf()
{
    conf_name=$1
    conf_file=$2

    echo -n "Please input $conf_name:"
    read conf_v

    old_conf_v=`grep $conf_name $conf_file`
    old_conf_v=`echo $old_conf_v`
    sed -i s/"$old_conf_v"/"$conf_name = $conf_v"/ $conf_file
}

deploy_confs()
{
    cd $1
    cp -f vimrc ~/.vimrc
    sudo cp -f vimrc /root/.vimrc
    cp -f gitconfig ~/.gitconfig

    change_conf "name" ~/.gitconfig
    change_conf "email" ~/.gitconfig

    vimdir=/usr/share/vim
    vimdirs=`ls $vimdir`
    for dir in $vimdirs
    do
        if [ `echo $dir | grep -c ^vim[1-9][0-9]` -eq 1 ]; then
            sudo cp -rf vim-plugin/* $vimdir/$dir/plugin/
        fi
    done

    cd -
}

set -e
sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
sudo apt-get update
pkgs=(vim git apache2 vsftpd subversion exuberant-ctags ksnapshot
wireshark chkconfig virtualbox cpanminus git-svn openssh-server
gitk minicom nfs-kernel-server cscope adobe-flashplugin skype
dos2unix apt-file rdesktop iptux autoconf libtool clang libncurses5-dev
unrar lrzsz pinta fcitx-table-wbpy wput qrfcview)

if [ ! -f /sbin/insserv ]; then 
	sudo ln -s /usr/lib/insserv/insserv /sbin/insserv
fi

for pkg in ${pkgs[@]}
do
    sudo apt-get install -y $pkg
done

cpanpkgs=(SourceCode::LineCounter::Perl Proc::Daemon)

for cpkg in ${cpanpkgs[@]}
do
    sudo cpanm $cpkg
done

resource_dir=~/resourcebackup-code
if [ ! -d $resource_dir ]; then
	git clone git://git.code.sf.net/p/resourcebackup/code $resource_dir
fi
deploy_scripts $resource_dir/scripts
deploy_confs $resource_dir/conf
