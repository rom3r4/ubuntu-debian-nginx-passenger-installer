#!/bin/sh

apt-get install python

$MAKE=`which make`
$GIT=`which git`

$DOWNLOAD_DIR=/tmp/nodejs

alias cd_tmp="cd $DOWNLOAD_DIR"

if [ ! -x $MAKE ];then
  echo ""
  echo "make not found"
  exit 1
fi

if [ ! -x $MAKE ];then
  echo ""
  echo "git installed? .. exiting"
  exit 1
fi


git clone https://github.com/joyent/node.git $DOWNLOAD_DIR
cd_tmp;git checkout v0.6.8

if [ ! -d $DOWNLOAD_DIR ];then
fi

$DOWNLOAD_DIR/configure --openssl-libpath=/usr/lib/ssl


cd_tmp;sudo $MAKE 
cd_tmp;sudo $MAKE install
RESULT=$?

if [ $RESULT -ne 0 ];then
  echo ""
  echo "Ooops. Installation failed :-("
  exit 1
fi

echo ""
echo "Installing npm ..."
cd_tmp;curl https://npmjs.org/install.sh | sudo sh

