## Welcome to YAAB (yet another automated builder )

This is a new inhouse tool that is used to build and maitian armhf images. 

This Tool was built and tested on Debian Jessie

### The common folder

These are scripts are imported into other parts of the program. 

common/customBuild

If you are building your own distro then you want to alter this file to add all things that you want your distro to contian
This also reads from the file extraPackages 

example: custom apps custom configuration's 

common/extraPackages 

These are the extra packages that are installed to you operating system, this is read when customBuild runs.

common/htmlHelper

Set of bash funtions that are used to make the output web interface

common/common.sh 

This is the main configureations for building the odroid images.  You This is where you alter the distro type and versions and many other things

common/deps

Script that is used to make sure that all depenceys are install to the host machine that is building images


common/toochains

This script is used to check and make sure that you have all the toolkits installed for cross compiling uboot and the linux kernel

### The config folder 

At the end of each build there is a web folder in the odroid-<Version>-<codename>/web folder. These are al put together as the image is building. and have all the logs for the build. 

config/header.html

Part of the templeating web interface that is used to write headers to webpages 


config/body.html 

Part of the templeating web interface that is used to write bodys to webpages

config/footer

Part of the templeating web interface that is used to write footer to webpages, this is also used to close all html tags in the body and header
typical script.. 

config/header.html 

the header of the webpages


config/body.html 

the Body of each page for hrml debuggin output

### The static dir 

This directory contains all the static javascript and css that is used in the web out put for debugging

### The Arcive Folder

This is a cache folder,  This holds all of the compressed toolkits If there is none it downloads them


### The Toolchain folder

This is used after downloading all of the toolkits.  This is where all the cosscompilers are exstracted to

!! THANKS LINARO !!


### The Boards Folder: 

These are custom sctipts that are used for custom boards There are arranged like this. 

board<vendor><name of board>/files


Example 

There is a X folder that has all the config's for odroid-xu4's and there is a C folder for all the odroid-C specific things

example:  a odroidc1 might  need a custom /etc/securetty file


### The Web Dir

Yaab comes with a webinteface that can be used to build images.  for more info on this see the web/README.md file. 



