#!/bin/bash

set -e

if [ $# -ne 1 ]; then
    echo "Please input Opencv code dir!"
    exit 1
fi

OPENCV_DIR=$1

if [ ! -d $OPENCV_DIR ]; then
    echo "$OPENCV_DIR not exist!"
    exit 1
fi

sudo apt-get -y install build-essential libgtk2.0-dev libjpeg-dev libtiff4-dev libjasper-dev libopenexr-dev cmake python-dev python-numpy python-tk libtbb-dev libeigen2-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libqt4-dev libqt4-opengl-dev sphinx-common texlive-latex-extra libv4l-dev libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev

dep_libs=()
cd /usr/lib
sudo ln -s /usr/lib/x86_64-linux-gnu/libImath.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libIlmImf.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libIex.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libHalf.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libIlmThread.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libpython2.7.so
cd -

cd $OPENCV_DIR
mkdir -p release
cd release

cmake -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -DINSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -DBUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..

make
sudo make install
sudo ldconfig
