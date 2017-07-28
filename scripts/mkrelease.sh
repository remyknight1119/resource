#!/bin/bash

set -e

usage()
{
    echo -n "$0 -p [product_name] -m [major_version] -n [minor_version] -r [revised_version] "
    echo "-d [output_dir] -o [iso_file_dir] -u [server_url] -l [mail_list] -e -w -i"
}

unset EDIT_EMAIL
while getopts ":p:m:r:d:n:o:u:l:ewi" Option
do
    case $Option in
        p)
            PRODUCT_NAME=$OPTARG
            ;;
        m)
            MAJOR_VERSION=$OPTARG
            ;;
        n)
            MINOR_VERSION=$OPTARG
            ;;
        r)
            REVISED_VERSION=$OPTARG
            ;;
        d)
            OUTPUT_DIR=$OPTARG
            ;;
        o)
            ISO_DIR=$OPTARG
            ;;
        u)
            SERVER_URL=$OPTARG
            ;;
        l)
            MAIL_LIST=$OPTARG
            ;;
        e)
            EDIT_EMAIL='y'
            ;;
        w)
            WITHOUT_SUBDIR='y'
            ;;
        i)
            INSTALL_ONLY='y'
            ;;
    esac
done

if [ 'x' = x$PRODUCT_NAME ]; then
    echo "please input product name by -p"
    usage
    exit 1
fi

if [ 'x' = x$MAJOR_VERSION ]; then
    echo "please input major version by -m"
    usage
    exit 1
fi

if [ 'x' = x$MINOR_VERSION ]; then
    echo "please input minor version by -n"
    usage
    exit 1
fi

if [ 'x' = x$REVISED_VERSION ]; then
    echo "please input revised version by -r"
    usage
    exit 1
fi

if [ 'x' = x$SERVER_URL ]; then
    echo "please input rpm server url by -u"
    usage
    exit 1
fi

FTP_ROOT="/var/ftp"
OUTPUT_NAME=`date  +%Y%m%d-%H%M`

if [ x != x$MAIL_LIST ]; then
    RECIPIENT=`cat $MAIL_LIST`
    OUTPUT_DIR=$FTP_ROOT/$OUTPUT_NAME
elif [ x = x$OUTPUT_DIR ]; then
    echo "please input output dir with -o"
    usage
    exit 1
fi

if [ -d $OUTPUT_DIR ]; then
    rm -rf $OUTPUT_DIR/* 
else
    /usr/bin/sudo mkdir -p $OUTPUT_DIR 
    sudo chmod a+w $OUTPUT_DIR 
fi

get_rpms()
{
    sudo rm -f $OUTPUT_DIR/*.rpm

    if [ ! -z $WITHOUT_SUBDIR ]; then
        cp -f $PACKAGE_DIR/*.rpm $OUTPUT_DIR
        return
    fi

    DIRS=`ls -d $PACKAGE_DIR/*/`
    for rpmsdir in $DIRS
    do
        SUB_DIRS=`ls -d $rpmsdir/*/`
        for subdir in $SUB_DIRS
        do
            LATEST_RPM=`ls -t $subdir | head -n 1`
            RPMS_DIR=`basename $rpmsdir`
            mkdir -p ${OUTPUT_DIR}/$RPMS_DIR
            cp ${subdir}/$LATEST_RPM ${OUTPUT_DIR}/$RPMS_DIR
        done
    done
}

RELEASE_NAME=${PRODUCT_NAME}-${MAJOR_VERSION}.${MINOR_VERSION}-${REVISED_VERSION}
if [ -d $SERVER_URL ]; then
    PACKAGE_DIR=$SERVER_URL 
    get_rpms
else
    PROTO=`echo $SERVER_URL | cut -d '/' -f 1`
    PACKAGE_DIR=`echo $SERVER_URL | sed "s/${PROTO}\/\///"`
    sudo rm -rf $PACKAGE_DIR
    wget -m --accept=.rpm $SERVER_URL 
    get_rpms
    sudo rm -rf $PACKAGE_DIR
fi

#Generate release info RPM
RELEASE_INFO_SPEC=${HOME}/adsg-releaseinfo.spec
RELEASE_INFO_NAME=adsg-release
cat > $RELEASE_INFO_SPEC <<ENDOFFILE
Name:       $RELEASE_INFO_NAME
Version:    ${MAJOR_VERSION}.${MINOR_VERSION}
Release:    ${REVISED_VERSION}%{?dist}
Summary:    adsg release info
License:    Commercial
Group:      Applications/System
Prefix:     /opt
%description
NetEye ADSG release

%prep

%pre

%install
%define __os_install_post %{nil}

rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/adsg/release-info
cat > %{buildroot}/opt/adsg/release-info/release-info_en_US.xml <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Release>
<ProductName>Neusoft NetEye ADSG</ProductName>
<Version>
<Major>${MAJOR_VERSION}</Major>
<Minor>${MINOR_VERSION}</Minor>
<Patch>${REVISED_VERSION}</Patch>
</Version>
<Copyright>Copyright (c) 2010-2013 Shenyang Neusoft System Integration Co., Ltd.</Copyright>
</Release>
EOF

cat > %{buildroot}/opt/adsg/release-info/release-info_zh_CN.xml <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Release>
<ProductName>Neusoft NetEye ADSG</ProductName>
<Version>
<Major>${MAJOR_VERSION}</Major>
<Minor>${MINOR_VERSION}</Minor>
<Patch>${REVISED_VERSION}</Patch>
</Version>
<Copyright>版权所有 (c) 2010-2013 沈阳东软系统集成工程有限公司</Copyright>
</Release>
EOF

cat > %{buildroot}/opt/adsg/release-info/release-info.txt <<EOF
Neusoft NetEye ADSG ${MAJOR_VERSION}.${MINOR_VERSION}-${REVISED_VERSION}
EOF


%files
%defattr(-,root,root,-)

# all files
/opt/adsg/release-info/*

%changelog

%post

%preun

%postun
ENDOFFILE

rpmbuild -bb $RELEASE_INFO_SPEC
HOSTTYPE=`uname -m`
RPM_PATH=${HOME}/rpmbuild/RPMS/$HOSTTYPE
DIST=`uname -r | cut -d '.' -f 4`
cp ${RPM_PATH}/${RELEASE_INFO_NAME}-${MAJOR_VERSION}.${MINOR_VERSION}-${REVISED_VERSION}.${DIST}.${HOSTTYPE}.rpm $OUTPUT_DIR

#Generate install
INSTALL=install
TGZ=neteye.tgz

INSTALL_PKG=${RELEASE_NAME}.install

PACKAGE_DIR=neteye
SETUP_SH=install_all.sh

if [ -d $PACKAGE_DIR ]; then
    rm -rf $PACKAGE_DIR 
fi
mkdir $PACKAGE_DIR
cat > $PACKAGE_DIR/$SETUP_SH <<'EOF'
#!/bin/bash
# Copyright Neusoft,2011~2016

set -e

TMP_DIR=/tmp

prepare_rpms()
{
    yum install -y python-psycopg2
    yum install -y patch
    yum install -y postgresql-server
    yum install -y fontforge
    yum install -y java-1.7.0-openjdk
    yum install -y liberation-fonts-common
    yum install -y liberation-sans-fonts
    yum install -y sgpio
    yum install -y python-twisted-web
    yum install -y PyGreSQL
    yum groupinstall -y chinese-support
}

unset HAVE_SPLASH
process_splash()
{
    SPLASH_NAME=adsg-splash
    SPLASH_RPM=`ls ${SPLASH_NAME}-[0-9]*.rpm | sed 's/.rpm//'`
    if `rpm -q $SPLASH_NAME >/dev/null` ; then
        HAVE_SPLASH=y
        if [ `rpm -q $SPLASH_NAME | grep -c $SPLASH_RPM` -ne 1 ] ; then
            rpm -U $SPLASH_NAME*.rpm 
        fi
    fi
    rm -f $SPLASH_NAME*.rpm 
}

install_all_rpms()
{
    RPMS=`ls *.rpm`
    unset UPGREAD

    for rpm_pkg in $RPMS
    do
        rpm_name=`echo $rpm_pkg | sed s/\.rpm//`
        if [ `rpm -qa | grep -c $rpm_name` -eq 1 ]; then
            echo "$rpm_name no need update!"
            UPGREAD=y
            rm -f $rpm_pkg
            continue
        fi
        i=1
        unset rpm_key
        while :
        do
            cut_part=`echo $rpm_name | cut -d '-' -f $i` 
            if [ `echo $cut_part | grep ^[0-9] -c` -ne 0 ]; then
                break
            fi
            if [ -z $rpm_key ]; then
                rpm_key=$cut_part 
            else
                rpm_key=${rpm_key}-$cut_part 
            fi
            i=$((i + 1))
        done
        if `rpm -q $rpm_key >/dev/null`; then
            UPGREAD=y
        fi
    done

    if [ -z $UPGREAD ]; then
        prepare_rpms
    fi

    if `ls *.rpm 1>/dev/null 2>&1`; then
        /usr/bin/sudo rpm -Uvh *.rpm 
    fi

    ADMIN_USER=admin
    if [ x = x$HAVE_SPLASH -a -d /home/$ADMIN_USER ]; then
        userdel admin
        rm -rf /home/$ADMIN_USER
    fi
}

# Clean env
clean_env()
{
    rm -fr $TMP_DIR/neteye >/dev/null 2>&1
}

disable_selinux()
{
    setenforce 0
    SELINUX_CONF=/etc/selinux/config
    SELINUX_CONF_LINE=`grep -n ^SELINUX= $SELINUX_CONF | cut -d ':' -f 1`
    sed -i "${SELINUX_CONF_LINE}s/enforcing/permissive/" $SELINUX_CONF
}

# Now, let's GO

process_splash
install_all_rpms
echo "Install succeed!"
disable_selinux
clean_env
EOF
chmod 755 $PACKAGE_DIR/$SETUP_SH

OUTPUT_RPMS=`find $OUTPUT_DIR | sed "s/^\.\///" | grep .rpm$`
for output_rpm in $OUTPUT_RPMS
do
    cp -f $output_rpm $PACKAGE_DIR
done

if [ -z $INSTALL_ONLY ]; then
    #Generate iso
    GIT_REPO=ssh://build@adsg-repo:29418/adsg-system
    if [ -z $ISO_DIR ]; then
        ISO_DIR=`basename $GIT_REPO`
    fi

    if [ -d $ISO_DIR ]; then
        cd $ISO_DIR 
        git checkout *
        git pull
        OLD_RPMS=`git status | awk '{print $2}' | grep Packages | grep rpm$`
        for old_rpm in $OLD_RPMS
        do
            rm -f $old_rpm 
        done
        cd -
    else
        git clone $GIT_REPO $ISO_DIR
    fi
    ${ISO_DIR}/scripts/mkiso.pl -d $PACKAGE_DIR -o $ISO_DIR -p $OUTPUT_DIR -n ${RELEASE_NAME}.$HOSTTYPE
fi

#Generate install
echo
echo -n "Building $TGZ..."
tar czf $TGZ $PACKAGE_DIR
echo "done"
echo

echo -n "Building $OUTPUT_DIR/$INSTALL_PKG..."

cat > $INSTALL <<'EOF'
#!/bin/sh

tmpdir=/tmp
prog="${tmpdir}/neteye/install_all.sh"
if [ -d $tmpdir/neteye ]; then
    rm -rf $tmpdir/neteye
fi
if tail -n +19 "$0"|tar -zxpf - -C ${tmpdir}; then
    cd $tmpdir/neteye
    if [ x$1 = 'xunpkg' ]; then
        exit 0
    fi
    source $prog $*
    exit 0
else	
    echo "Can't decompress $0"	
    exit 1
fi 
EOF

cat $INSTALL $TGZ > $OUTPUT_DIR/$INSTALL_PKG
chmod +x $OUTPUT_DIR/$INSTALL_PKG
echo "done in $OUTPUT_DIR"
rm -rf $PACKAGE_DIR
rm -f $INSTALL 
rm -f $TGZ

RELEASE_SERVER_IP=`/sbin/ifconfig -a | grep -A 2 Ethernet | grep "inet addr" | head -n 1 | awk '{print $2}' | cut -d ':' -f 2`

send_build_message()
{
    local OUTPUT_PATH=$1
    local TITLE="$2 release"
    local FTP_SERVER_IP=$3
    local OUTPUT_DIR_NAME=`basename $OUTPUT_PATH`
    local FTP_URL="ftp://${FTP_SERVER_IP}/${OUTPUT_DIR_NAME}"
    local MASSAGE_FILE=${HOME}/adsg-build-msginfo.txt

    echo "Output:" > $MASSAGE_FILE

    cd $OUTPUT_PATH
    OUTPUT_FILES=`find | sed "s/^\.\///" | grep .rpm$`
    for output_file in $OUTPUT_FILES
    do
        echo "${FTP_URL}/$output_file" >> $MASSAGE_FILE
    done
    INSTALL_FILE=`ls *.install`
    ISO_FILE=`ls *.iso`
    echo  >>  $MASSAGE_FILE
    echo "安装下面的文件即可完成对上述所有rpm包的安装：" >> $MASSAGE_FILE
    echo  >>  $MASSAGE_FILE
    echo "******************************************************************" >> $MASSAGE_FILE
    echo "${FTP_URL}/$INSTALL_FILE" >> $MASSAGE_FILE
    echo "${FTP_URL}/$ISO_FILE" >> $MASSAGE_FILE
    echo "******************************************************************" >> $MASSAGE_FILE
    cat >> $MASSAGE_FILE << EOF

ftp user: ftp
ftp passward: ftp

Enjoy!
EOF
    cd -
    if [ x$EDIT_EMAIL = 'xy' ]; then
        vim $MASSAGE_FILE
    fi

    /usr/bin/sudo mutt -s "$TITLE" $RECIPIENT < $MASSAGE_FILE
    rm -f $MASSAGE_FILE
}

if [ x = x"$RECIPIENT" ]; then
    echo "Not send email!"
else
    send_build_message $OUTPUT_DIR $RELEASE_NAME $RELEASE_SERVER_IP 
fi

if [ ! -z $INSTALL_ONLY ]; then
    exit
fi
MOUNT_DIR=/var/ftp/pub/adsg-img
KS_FILE=/var/ftp/pub/ks.cfg
ISO_FILE=`find $OUTPUT_DIR -name ${PRODUCT_NAME}*.iso`
if [ `df | grep -c $MOUNT_DIR` -ne 0 ]; then 
    sudo umount $MOUNT_DIR
fi
sudo mount -o loop $ISO_FILE $MOUNT_DIR 
sudo cp -f ${MOUNT_DIR}/isolinux/ks.cfg $KS_FILE 
sudo sed -i "s/^cdrom$/url --url ftp:\/\/${RELEASE_SERVER_IP}\/pub\/adsg-img/" $KS_FILE 
sudo sed -i '/^network/ d' $KS_FILE 
