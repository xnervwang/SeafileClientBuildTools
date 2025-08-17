#!/usr/bin/python2.7

# Copyright 2019-2025, Xnerv Wang <xnervwang@gmail.com>
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

from sets import Set
import os
import sys
import shutil
import subprocess

if 3 != len(sys.argv):
    print "Usage: %s [build_folder] [<MINGW32/MINGW64>]" % sys.argv[0]
    print "Example: %s ./ms-build/bin MINGW32" % sys.argv[0]
    print "Example: %s ./ms-build64/bin MINGW64" % sys.argv[0]
    sys.exit(1)

if not os.path.isdir(sys.argv[1]):
    print "Cannot find the target folder %s" % sys.argv[1]
    
if "MINGW32" == sys.argv[2]:
    mingw_path="/usr/i686-w64-mingw32/"
elif "MINGW64" == sys.argv[2]:
    mingw_path="/usr/x86_64-w64-mingw32/"
else:
    print "Unknown mode:", sys.argv[2]
    sys.exit(1)

build_path = os.path.join(sys.argv[1], "")

get_dep_cmd = "{mingw}/bin/objdump -p {{dll}}  | grep 'DLL Name' | sed 's/DLL Name: //g' | sed 's/[ \\t]//g'".format(mingw = mingw_path)
get_path_cmd = 'find {mingw} {build} {pwd} -name {{dll}}'.format(mingw = mingw_path, build = build_path, pwd = os.path.dirname(os.path.realpath(__file__)))

dlls = {
        build_path + "seafile-applet.exe": "seafile-applet.exe",
        build_path + "seaf-daemon.exe": "seaf-daemon.exe",
        mingw_path + "sys-root/mingw/lib/qt5/plugins/imageformats/qgif.dll": "imageformats/qgif.dll",
        mingw_path + "sys-root/mingw/lib/qt5/plugins/imageformats/qico.dll": "imageformats/qico.dll",
        mingw_path + "sys-root/mingw/lib/qt5/plugins/imageformats/qjpeg.dll": "imageformats/qjpeg.dll",
        mingw_path + "sys-root/mingw/lib/qt5/plugins/platforms/qminimal.dll": "platforms/qminimal.dll",
        mingw_path + "sys-root/mingw/lib/qt5/plugins/platforms/qoffscreen.dll": "platforms/qoffscreen.dll",
        mingw_path + "sys-root/mingw/lib/qt5/plugins/platforms/qwindows.dll": "platforms/qwindows.dll"
    }

dllnames = Set()
for dll, name in dlls.items():
    if not os.path.exists(dll) or os.path.isdir(dll):
        print "The dll %s doesn't exist or is not a valid dll file." % dll
        sys.exit(1)
    dllnames.add(os.path.basename(dll))
    target_path = build_path + name
    if os.path.abspath(dll) != os.path.abspath(target_path):
        if not os.path.isdir(os.path.dirname(target_path)):
            os.makedirs(os.path.dirname(target_path))
        shutil.copyfile(dll, target_path)
        print "copy %s to %s." % (dll, target_path)

native_dlls = Set()

def scan_deps(dll):
    print "current dll:", dll
    names = subprocess.check_output(['bash','-c', get_dep_cmd.format(dll = dll)])
    print "dependency dlls:"
    names = names.splitlines()
    new_dlls = Set()
    for name in names:
        if name not in dllnames:
            print "find a name dll:", name
            dllnames.add(name)
            paths = subprocess.check_output(['bash','-c', get_path_cmd.format(dll = name)])
            paths = paths.splitlines()
            if len(paths) == 0:
                native_dlls.add(name)
            else:
                for path in paths:
                    print "paths:", len(paths)
                    print "path:", path
                new_dlls.add(paths[0])
                target_path = build_path + name
                if os.path.abspath(paths[0]) != os.path.abspath(target_path):
                    shutil.copyfile(paths[0], target_path)
                    print "copy %s to %s." % (paths[0], target_path)

    return new_dlls

    # After scanning all children, add this dll into dlls. Then if a dll is already in dlls,
    # it also means this dll had been scanned and we won't scan it again. This is DFS.

while True:
    new_dlls = Set()
    for dll in dlls:
        new_dlls = new_dlls.union(scan_deps(dll))
    if len(new_dlls) != 0:
        print "new_dlls:", new_dlls
        dlls = new_dlls
    else:
        print "Finished!"
        break
