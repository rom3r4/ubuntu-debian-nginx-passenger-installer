#!/bin/bash

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

  echo "Installing Passenger on a Debian box"
  IS_DEBIAN="yes"
  
elif [ "x$UBUNTU" != "x" ];then
  echo "Installing Passenger on a Ubuntu Box"
  IS_UBUNTU="yes"
  
else
  echo "debian or ubuntu box required..."
  echo "your system: '`uname -a`'"
  exit 1
  
fi


$APT_GET update


if [ "x$CURL" = "x" ];then
  echo "intalling cURL ..."
  apt-get install curl
fi

if [ "x$SUDO" = "x" ];then
  echo "intalling sudo ..."
  apt-get install sudo
fi

echo "Installing RVM stable with ruby"

curl -L get.rvm.io | bash -s stable

echo "Setting up progress bar when downloading RVM / Rubies..."

echo progress-bar >> ~/.curlrc

echo "Setting up rvmsudo_secure_path.."

echo "export rvmsudo_secure_path=1" >> ~/.profile

echo "Makeing --no-ri --no-rdoc the default for gem install (will save disk space)"

echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
 
echo "After it is done installing, load RVM."
source ~/.rvm/scripts/rvm


echo "In order to work, RVM has some of its own dependancies that need to be installed."
rvm requirements
RESULT=$?

if [ $RESULT -ne 0 ];then
  echo "error, can't continue, rvm is not detected. try rebooting your system"
  echo "close your tasks and type 'reboot' as toot"
  exit 1
fi

echo "Additional Dependencies:"
echo "For Ruby / Ruby HEAD (MRI, Rubinius, & REE), install the following:"

$RVMSUDO $APT_GET install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion

echo "adding Curl development headers with SSL support.."

# select
# $APT_GET install libcurl4-openssl-dev
# or: 
$APT_GET install libcurl4-gnutls-dev

echo "Once you are using RVM, installing Ruby is easy."

$RVM install 1.9.3

$RVM reload

# echo "Ruby is now installed. However, since we accessed it through a program that has a variety of Ruby versions, we need to tell the system to use 1.9.3 by default."
# $RVM use 1.9.3 --default

echo "The next step makes sure that we have all the required components of Ruby on Rails. We can continue to use RVM to install gems; type this line into terminal."
rvm rubygems current

echo "Once everything is set up, it is time to install Rails..."

gem install rails --no-ri --no-rdoc

echo "Adding also suppor for Sinatra..."

gem install sinatra --no-ri --no-rdoc

echo "Once Ruby on Rails is installed, go ahead and install passenger."

gem install passenger --no-ri --no-rdoc

echo "Here is where Passenger really shines. As we are looking to install Rails on an nginx server, we only need to enter one more line into terminal:"

$RVMSUDO passenger-install-nginx-module



echo "...And now Passenger takes over."

echo "The last step is to turn start nginx, as it does not do so automatically."

$SUDO service nginx start 

echo ""
echo ""
echo "Once you have rails installed, open up the nginx config file /opt/nginx/conf/nginx.conf"
echo ""
echo "type: sudo nano /opt/nginx/conf/nginx.conf"
echo ""
echo "write the text below, and save. Thats it"

cat << 'EOT'
server { 
  listen 80; 
  server_name example.com; 
  passenger_enabled on; 
  root /var/www/my_awesome_rails_app/public; 
}
EOT


echo "to create your new rails project, type: rails new my_awesome_rails_app"

