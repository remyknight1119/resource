#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Please input user name"
    exit 1
fi

SVN_CONF=/etc/subversion
SVNAUTH=$SVN_CONF/authz
USER_KEY="project_u"
USER_NAME=$1

htpasswd $SVN_CONF/passwd $USER_NAME
OLD_USERS=`grep ^$USER_KEY $SVNAUTH`
NEW_USERS="$OLD_USERS,$USER_NAME"
LINE_NUM=`grep -n ^$USER_KEY $SVNAUTH | cut -d ':' -f 1`
sed -i /^$USER_KEY/d $SVNAUTH
sed -i "$LINE_NUM i $NEW_USERS" $SVNAUTH
