#!/bin/sh

apt-get install python

MAKE=`which make`
GIT=`which git`


DOWNLOAD_DIR=/tmp/nodejs
if [ ! -d $DOWNLOAD_DIR ];then
  mkdir $DOWNLOAD_DIR
fi

# alias cd_tmp="cd $DOWNLOAD_DIR"

git_checkout () {
  cd $DONLOAD_DIR
  $GIT checkout v0.6.8
}

git_configure () {
  cd $DONLOAD_DIR
  $DOWNLOAD_DIR/configure --openssl-libpath=/usr/lib/ssl
}

make_install () {
 cd $DOWNLOAD_DIR
 $MAKE  
 sudo $MAKE install
 return $?
}

install_npm () {
  cd $DOWNLOAD_DIR
  curl https://npmjs.org/install.sh | sudo sh
  return $?
}

if [ ! -x $MAKE ];then
  echo ""
  echo "make not found"
  exit 1
fi

if [ ! -x $GIT ];then
  echo ""
  echo "git installed? .. exiting"
  exit 1
fi


$GIT clone https://github.com/joyent/node.git $DOWNLOAD_DIR
git_checkout
git_configure

make_install
RESULT=$?

if [ $RESULT -ne 0 ];then
  echo ""
  echo "Ooops. nodejs installation failed :-("
  exit 1
else
  echo ""
  echo "succeded"  
fi

echo ""
echo "Installing npm ..."
install_npm
RESULT=$?

if [ $RESULT -ne 0 ];then
  echo ""
  echo "Ooops. 'npm' installation failed :-("
  exit 1
else
  echo ""
  echo "succeded."  
fi

