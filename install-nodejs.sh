#!/usr/bin/env bash

CURL=`which curl`
APT_GET=`which apt-get`
RVMSUDO=`which rvmsudo`
RVM=`which rvm`
SUDO=`which sudo`

DEBIAN=`uname -a | grep -i "debian"`
UBUNTU=`uname -a | grep -i "ubuntu"`


IS_DEBIAN="no"
IS_UBUNTU="no"


if [ "x$DEBIAN" != "x" ];then
  
  echo ""
  echo "Installing Passenger on a Debian box"
  IS_DEBIAN="yes"
  
elif [ "x$UBUNTU" != "x" ];then
  echo ""
  echo "Installing Passenger on a Ubuntu Box"
  IS_UBUNTU="yes"
  
else
  echo ""
  echo "debian or ubuntu box required..."
  echo "your system: '`uname -a`'"
  exit 1
  
fi

echo "Installing Nodejs..."

if [ "x$IS_DEBIAN" = "xyes" ];then
  $CURL -L https://raw.github.com/julianromerajuarez/ubuntu-debian-nginx-passenger-installer/master/install-nodejs.debian.sh | bash
else
  $CURL -L https://raw.github.com/julianromerajuarez/ubuntu-debian-nginx-passenger-installer/master/install-nodejs.ubuntu.sh | bash  
fi


