#!/bin/bash

libs=(sed git mingw32-curl intltool vala libtool automake autoconf make cmake \
	mingw32-qt5-qtbase-devel mingw32-qt5-qttools-tools mingw32-pkg-config \
 	pkg-config unzip libuuid-devel libcurl-devel openssl-devel qt5-qtbase-devel \
	make qt5-qttools-devel doxygen wget sqlite-devel mingw32-qt5-qttools \
	mingw32-qt5-qmake python2 gcc g++)

sudo dnf install ${libs[@]} -y
