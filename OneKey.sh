#!/bin/bash

set -e

CUR=$(pwd)
pushd $CUR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

make HOST_OS=MINGW32
./ResolveDllDeps.py  ms-build/bin/ MINGW32

make HOST_OS=MINGW64
./ResolveDllDeps.py  ms-build64/bin/ MINGW64

make HOST_OS=

popd
