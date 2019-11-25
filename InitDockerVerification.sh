#!/bin/bash

docker rm fedora-seafile-build-server
docker image rm fedora-seafile-build
docker volume rm seafile-volume
rm -rf build
rm -rf ms-build
rm -rf ms-build64

set -e

docker image prune -f
mkdir build
mkdir ms-build
mkdir ms-build64

docker volume create seafile-volume
docker build -t fedora-seafile-build .
