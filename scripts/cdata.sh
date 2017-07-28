#/bin/sh

OS_NAME=`uname`

if [ x$OS_NAME = "xFreeBSD" ]; then
	CTAGS=/usr/local/bin/ctags
else
	CTAGS=ctags
fi
$CTAGS -R .
rm -fr cscope.*
curr=`pwd`
find $curr/ -name "*.[ch]" >cscope.files
find $curr/ -name "*.cpp" >>cscope.files
cscope -bRq
