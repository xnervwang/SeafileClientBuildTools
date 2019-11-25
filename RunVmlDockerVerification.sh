#!/bin/bash

set -e

docker build --rm -t fedora-seafile-build .
docker run --rm --name=fedora-seafile-build-server fedora-seafile-build
docker image prune -f
docker image rm fedora-seafile-build
