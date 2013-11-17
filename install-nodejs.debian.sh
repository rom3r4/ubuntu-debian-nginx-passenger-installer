#!/bin/sh

apt-get-install python

$MAKE=`which make`

if [ "x$MAKE" = "x" ];then
  echo "make not found"
  exit 1
fi

cd /tmp
git clone https://github.com/joyent/node.git /tmp/nodejs
cd /tmp/nodejs


git checkout v0.6.8

./configure --openssl-libpath=/usr/lib/ssl

$MAKE
$MAKE test 
sudo $MAKE install
RESULT=$?

if [ $RESULT -ne 0 ];then
  echo "Ooops. Installation failed :-("
  exit 1
fi

echo "Installing npm ..."
curl https://npmjs.org/install.sh | sudo sh

