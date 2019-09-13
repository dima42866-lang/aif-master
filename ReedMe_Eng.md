###########################################
#                                         #
#   aif-master script instalation         #
#   online to Dialog mode on ArchLinux    #
#                                         #
###########################################

Author Nick-Name: maximalisimus
E-Mail: maximalis171091@yandex.ru
 
Date: 20.08.2019

Editor: Notepad++
    end line: unix
    encoding: UTF-8
    
The starting point of the project: Architect Linux installer

This script is a full-featured installation of the ArchLinux system in pseudographic mode, using the dialog package.
The script can be used with any archlunux distribution. This wizard supports UEFI installation mode when you start the ArchLinux system in UEFI mode.

How to use this wizard?
2 important conditions must be observed:
1) run as root
2) availability of a configured Internet connection in the distribution

This script can be run from anywhere. 
It is enough to make one of the files - used and run it directly in the console.

$ chmod ugo+x aif/aif
$ sudo sh aif/aif

Then just follow the instructions of the master installation.

This script is temporarily absent 2 menu:

1) Final configuration of network connections
2) server Installation (ssh, apache, php, mysql)

2 of these menus will soon be included in the master installation. Please accept our apologies.

You can use the setup wizard for the different modes of use of the system ArchLinux.
For example, do not install the graphics component (xorg, display Manager, graphics card driver and others) and use the system completely in console mode.
Or install all the necessary packages to use as a Desktop PC - whether office or home computer.

We wish you good luck.


