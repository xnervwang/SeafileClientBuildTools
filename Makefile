THREADS = $(shell nproc)

# If You need to make Linux build, comment this line and output folder is ./build.
# If you need to make Windows build, uncomment this line and output folder is ./ms-build.
# We can try x64 build in the future.
HOST_OS = MINGW32
$(info HOST_OS: $(HOST_OS))
CUR_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
$(info CUR_DIR: $(CUR_DIR))

JANSSONDIR       = jansson-master
LIBEVENTDIR      = libevent-master
LIBSEARPCDIR     = libsearpc-master
SEAFILEDIR       = seafile-master
SEAFILECLIENTDIR = seafile-client-master

ifeq ($(HOST_OS), MINGW32)
HOST = i686-w64-mingw32
BUILD = x86_64-redhat-linux-gnu
TARGET = i686-w64-mingw32
PREFIX = $(shell pwd)/ms-build
OPTION = --host=$(HOST) --build=$(BUILD) --target=$(TARGET)
TOOLCHAIN = -DCMAKE_TOOLCHAIN_FILE=$(CUR_DIR)Toolchain-cross-linux.i686.cmake
export PATH = $(PREFIX)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin
export PKG_CONFIG = mingw32-pkg-config
export PKG_CONFIG_PATH = /usr/$(TARGET)/sys-root/mingw/lib/pkgconfig:$(PREFIX)/lib/pkgconfig
export C_INCLUDE_PATH = $(PREFIX)/include:/usr/$(TARGET)/sys-root/mingw/include
export CPLUS_INCLUDE_PATH = $(PREFIX)/include
export PYTHON_DIR =  $(PREFIX)/python
else
ifeq ($(HOST_OS), MINGW64)
HOST = x86_64-w64-mingw32
BUILD = x86_64-redhat-linux-gnu
TARGET = x86_64-w64-mingw32
PREFIX = $(shell pwd)/ms-build64
OPTION = --host=$(HOST) --build=$(BUILD) --target=$(TARGET)
TOOLCHAIN = -DCMAKE_TOOLCHAIN_FILE=$(CUR_DIR)Toolchain-cross-linux.x86_64.cmake
export PATH = $(PREFIX)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin
export PKG_CONFIG = mingw64-pkg-config
export PKG_CONFIG_PATH = /usr/$(TARGET)/sys-root/mingw/lib/pkgconfig:$(PREFIX)/lib/pkgconfig
export C_INCLUDE_PATH = $(PREFIX)/include:/usr/$(TARGET)/sys-root/mingw/include
export CPLUS_INCLUDE_PATH = $(PREFIX)/include
export PYTHON_DIR =  $(PREFIX)/python
else
PREFIX = $(shell pwd)/build
export PATH = $(PREFIX)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin
export PKG_CONFIG_PATH = $(PREFIX)/lib/pkgconfig
export C_INCLUDE_PATH = $(PREFIX)/include
export CPLUS_INCLUDE_PATH = $(PREFIX)/include
export PYTHON_DIR =  $(PREFIX)/python
endif
endif

.PHONY: default

# Since empty depends on rmzips and make is based on rules, I guess make would finish rmzips
# before default and init. Since the same reason init would be finished before default,
# so if default depends on empty, the final execution order would be rmzips-->init-->default.
# We shouldn't regard the target list as the execution order.
# 
default: clean init seafile-client

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
	if test -f "$(SEAFILECLIENTDIR)/Makefile"; then make -C $(SEAFILECLIENTDIR) clean; fi;\
	if test -f "$(LIBEVENTDIR)/Makefile"; then make -C $(LIBEVENTDIR) clean; fi;\
	if test -f "$(JANSSONDIR)/Makefile"; then make -C $(JANSSONDIR) clean; fi;\
	if test -f "$(LIBSEARPCDIR)/Makefile"; then make -C $(LIBSEARPCDIR) clean; fi;\
	if test -f "$(SEAFILEDIR)/Makefile"; then make -C $(SEAFILEDIR) clean; fi;

-rm-builds:
	rm -rf build
	rm -rf ms-build
	rm -rf ms-build64

clean-all: clean -rm-builds

empty: rmzips -rm-builds
	rm -rf $(SEAFILECLIENTDIR);\
	rm -rf $(LIBEVENTDIR);\
	rm -rf $(JANSSONDIR);\
	rm -rf $(LIBSEARPCDIR);\
	rm -rf $(SEAFILEDIR)
