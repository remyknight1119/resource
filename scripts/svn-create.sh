#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Please input repo name"
    exit 1
fi

SVN_REPO=/svn
REPO_NAME=$1
REPO_PATH=$SVN_REPO/$REPO_NAME
SVNAUTH=/etc/subversion/authz

svnadmin create $REPO_PATH
chown apache:apache -R $REPO_PATH
chmod 777 $REPO_PATH

cat >> $SVNAUTH <<EOF
[$REPO_NAME:/]
@project_p = rw
@project_u = rw
* =
EOF
