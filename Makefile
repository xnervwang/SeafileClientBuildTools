THREADS = $(shell nproc)

# If You need to make Linux build, comment this line and output folder is ./build.
# If you need to make Windows build, uncomment this line and output folder is ./ms-build.
# We can try x64 build in the future.
HOST_OS = MINGW32

JANSSONDIR       = jansson-master
LIBEVENTDIR      = libevent-master
LIBSEARPCDIR     = libsearpc-master
SEAFILEDIR       = seafile-master
SEAFILECLIENTDIR = seafile-client-master

ifeq ($(HOST_OS),)
PREFIX = $(shell pwd)/build
export PATH = $(PREFIX)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin
export PKG_CONFIG_PATH = $(PREFIX)/lib/pkgconfig
export C_INCLUDE_PATH = $(PREFIX)/include
export CPLUS_INCLUDE_PATH = $(PREFIX)/include
export PYTHON_DIR =  $(PREFIX)/python
else
HOST = i686-w64-mingw32
BUILD = x86_64-redhat-linux-gnu
TARGET = i686-w64-mingw32
PREFIX = $(shell pwd)/ms-build
OPTION = --host=$(HOST) --build=$(BUILD) --target=$(TARGET)
TOOLCHAIN = -DCMAKE_TOOLCHAIN_FILE=/home/Toolchain-cross-linux.cmake
export PATH = $(PREFIX)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin
export PKG_CONFIG = mingw32-pkg-config
export PKG_CONFIG_PATH = /usr/$(TARGET)/sys-root/mingw/lib/pkgconfig:$(PREFIX)/lib/pkgconfig
export C_INCLUDE_PATH = $(PREFIX)/include:/usr/$(TARGET)/sys-root/mingw/include
export CPLUS_INCLUDE_PATH = $(PREFIX)/include
export PYTHON_DIR =  $(PREFIX)/python
endif

.PHONY: default

default: init seafile-client

fetch:
	wget -q -O $(JANSSONDIR).zip https://github.com/akheron/jansson/archive/master.zip;\
	wget -q -O $(LIBEVENTDIR).zip https://github.com/libevent/libevent/archive/master.zip;\
	wget -q -O $(LIBSEARPCDIR).zip https://github.com/haiwen/libsearpc/archive/master.zip;\
	wget -q -O $(SEAFILEDIR).zip https://github.com/xnervwang/seafile/archive/master.zip;\
	wget -q -O $(SEAFILECLIENTDIR).zip https://github.com/xnervwang/seafile-client/archive/master.zip

extract:
	rm -rf $(JANSSONDIR);\
	rm -rf $(LIBEVENTDIR);\
	rm -rf $(LIBSEARPCDIR);\
	rm -rf $(SEAFILEDIR);\
	rm -rf $(SEAFILECLIENTDIR);\
	unzip $(JANSSONDIR).zip;\
	unzip $(LIBEVENTDIR).zip;\
	unzip $(LIBSEARPCDIR).zip;\
	unzip $(SEAFILEDIR).zip;\
	unzip $(SEAFILECLIENTDIR).zip

rmzips:
	rm -f $(JANSSONDIR).zip;\
	rm -f $(LIBEVENTDIR).zip;\
	rm -f $(LIBSEARPCDIR).zip;\
	rm -f $(SEAFILEDIR).zip;\
	rm -f $(SEAFILECLIENTDIR).zip

init: fetch extract rmzips

jansson:
	cd $(JANSSONDIR);\
	autoreconf -i;\
	./configure --prefix=$(PREFIX) $(OPTION);\
	make -j $(THREADS);\
	make install

libevent:
	cd $(LIBEVENTDIR);\
	autoreconf -i;\
	./configure --prefix=$(PREFIX) $(OPTION);\
	make -j $(THREADS);\
	make install

libsearpc: jansson libevent
	cd $(LIBSEARPCDIR);\
	sed -i 's/build_os/host_os/g' configure.ac;\
	bash ./autogen.sh;\
	./configure --prefix=$(PREFIX) $(OPTION);\
	make -j $(THREADS);\
	make install

seafile: libsearpc
	cd $(SEAFILEDIR);\
	sed -i 's/Rpc.h/rpc.h/g' lib/utils.c;\
	sed -i 's/build_os/host_os/g' configure.ac;\
	sed -i 's/lRpcrt4/lrpcrt4/g' configure.ac;\
	sed -i 's/AccCtrl.h/accctrl.h/g' daemon/set-perm.c;\
	sed -i 's/AclApi.h/aclapi.h/g' daemon/set-perm.c;\
	bash ./autogen.sh;\
	./configure --prefix=$(PREFIX) $(OPTION);\
	make -j $(THREADS);\
	make install

seafile-client: seafile
	cd $(SEAFILECLIENTDIR);\
	sed -i 's/ShlObj.h/shlobj.h/g' src/ui/init-seafile-dialog.cpp;\
	cmake $(TOOLCHAIN) -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(PREFIX);\
	make -j $(THREADS);\
	make install

clean:
	make -C $(SEAFILECLIENTDIR) clean;\
	make -C $(LIBEVENTDIR) clean;\
	make -C $(JANSSONDIR) clean;\
	make -C $(LIBSEARPCDIR) clean;\
	make -C $(SEAFILEDIR) clean
	rm -rf build
	rm -rf ms-build

empty: rmzips
	rm -rf $(SEAFILECLIENTDIR);\
	rm -rf $(LIBEVENTDIR);\
	rm -rf $(JANSSONDIR);\
	rm -rf $(LIBSEARPCDIR);\
	rm -rf $(SEAFILEDIR)
