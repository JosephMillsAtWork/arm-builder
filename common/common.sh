#!/bin/bash
## this is used for all commomn things like toochains and
## the distro="debian"
## ones that are supported

## this is the dir that is used to tell where odroid builder is installed
rootDir="/home/joseph/Work/sandy/odroidBuilder"
echo "root dir is set to $rootDir"

## TODO add in the pi and other boards later on
manufacturer="odroid"


## The type of board that you are building for example U is for the U series of
## of the odroid boards
## Only U and C are ready at this point
board="X"
echo "the type of odroid board if set to $board"

## IMPORTANT make sure that this all all lower case.
distro="debian"

echo "Distro set to $distro"

## the version of the distro="debian"
codeName="jessie"


## the version of the build"
version=2.0

echo "Versions of this mangoES has been set to $version"
## the host arch.  This only needs to be set if it tells you to set it
# hostArch=""

## variant used to for debootstrap
debootstrapVariant="buildd"
echo "Debootstraps variant has been set to $debootstrapVariant "

co=$(grep -c processor /proc/cpuinfo)
minueOne=1
cnum=$(expr $co - $minueOne)
buildArch="armhf"

status=0


#the sandboxed area where the build will be built
outDir=$manufacturer-$version-$board-$codeName
basedir=$(pwd)/$outDir


addDesktop=0
desktopName=""


## Mirrors for Ubuntu and Debian"
if [[ $distro == "debian" ]];
then
    mainMirror="http://http.debian.net/debian"
    securityMirror="security.debian.org/"
else 
    mainMirror="http://ports.ubuntu.com/ubuntu-ports/"
fi


echo "Security Mirrors and Debian Mirrors have been setup "
# these are paths to the downloaded cross compile. TODO
gcc49="$rootDir/toolkits/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin"
gcc47="$rootDir/toolkits/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin"
eabi="$rootDir/toolkits/arm-eabi-4.4.3/bin"
eabiNone="$rootDir/toolkits/gcc-linaro-arm-none-eabi-4.8-2014.04_linux/bin"
