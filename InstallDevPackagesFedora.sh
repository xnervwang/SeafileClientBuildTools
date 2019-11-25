#!/bin/bash

libs=(sed gcc g++ automake autoconf make cmake python2 \
 	libuuid-devel libcurl-devel openssl-devel sqlite-devel \
	git doxygen wget pkg-config unzip intltool vala libtool \
	qt5-qtbase-devel qt5-qttools-devel \
	mingw32-curl mingw64-curl \
	mingw32-qt5-qtbase-devel mingw64-qt5-qtbase-devel \
	mingw32-qt5-qttools-tools mingw64-qt5-qttools-tools \
	mingw32-pkg-config mingw64-pkg-config \
	mingw32-qt5-qttools mingw64-qt5-qttools \
	mingw32-qt5-qmake mingw64-qt5-qmake)

sudo dnf install ${libs[@]} -y
