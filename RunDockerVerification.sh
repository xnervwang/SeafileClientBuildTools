#!/bin/bash

set -e

docker run --rm -v $(pwd)/build:/SeafileClientBuildTools/build -v $(pwd)/ms-build:/SeafileClientBuildTools/ms-build -v $(pwd)/ms-build64:/SeafileClientBuildTools/ms-build64 --name=fedora-seafile-build-server fedora-seafile-build
