#!/bin/bash

set -e

opencv_dir=$1

if [ ! -d $opencv_dir ]; then
    echo "$opencv_dir is not exist!"
    exit 1
fi

sudo apt-get install build-essential libgtk2.0-dev libjpeg-dev libtiff4-dev libjasper-dev libopenexr-dev cmake python-dev python-numpy python-tk libtbb-dev libeigen2-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libqt4-dev libqt4-opengl-dev sphinx-common texlive-latex-extra libv4l-dev libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev

cd $opencv_dir
mkdir release
cd release
cmake -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -DINSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -DBUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..
make
sudo make install
sudo cat > /etc/ld.so.conf.d/opencv.conf <<EOF
/usr/local/lib
EOF
sudo ldconfig
