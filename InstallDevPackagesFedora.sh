#!/bin/bash

# Copyright 2025, Xnerv Wang <xnervwang@gmail.com>
#
# Redistribution and use in source and binary forms, with or 
# without modification, are permitted provided that the 
# following conditions are met:
#
# 1. Redistributions of source code must retain the above 
#    copyright notice, this list of conditions and the 
#    following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above 
#    copyright notice, this list of conditions and the 
#    following disclaimer in the documentation and/or other 
#    materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names 
#    of its contributors may be used to endorse or promote 
#    products derived from this software without specific 
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
