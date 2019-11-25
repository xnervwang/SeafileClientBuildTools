# SeafileClientBuildTools

Current we support building Seafile client(i686/x86_64) for Windows/Linux on Fedora development environment. We may support more Linux distributions in the future.

## Initialize and build
When you are in Fedora, run `Install-dev-packages-Fedora.sh` script to install all necessray packages firstly.

## How to build Windows client
Run `make` or `make HOST_OS=MINGW32` and get i686 32-bits ./ms-build folder.
Run `make HOST_OS=MINGW64` and get x86_64-bits ./ms-build64 folder.

## How to build Linux client
Run `make HOST_OS=` and get ./build folder.

## How to run docker script
