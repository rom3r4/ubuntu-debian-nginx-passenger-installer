#!/bin/sh

apt-get install python

$MAKE=`which make`
$DOWNLOAD_DIR=/etc/nodejs
if [ "x$MAKE" = "x" ];then
  echo ""
  echo "make not found"
  exit 1
fi


git clone https://github.com/joyent/node.git $DOWNLOAD_DIR
cd $DOWNLOAD_DIR;git checkout v0.6.8

if [ ! -d $DOWNLOAD_DIR ];then
fi

$DOWNLOAD_DIR/configure --openssl-libpath=/usr/lib/ssl


cd $DOWNLOAD_DIR;sudo $MAKE 
cd $DOWNLOAD_DIR;sudo $MAKE install
RESULT=$?

if [ $RESULT -ne 0 ];then
  echo ""
  echo "Ooops. Installation failed :-("
  exit 1
fi

echo ""
echo "Installing npm ..."
cd $DOWNLOAD_DIR;curl https://npmjs.org/install.sh | sudo sh

