#!/usr/bin/env bash

CURL=`which curl`
APT_GET=`which apt-get`
RVMSUDO=`which rvmsudo`
RVM=`which rvm`
SUDO=`which sudo`

DEBIAN=`uname -a | grep -i "debian"`
UBUNTU=`uname -a | grep -i "ubuntu"`


# INSTALLATION_DIR="/tmp/nginx_install"

IS_DEBIAN="no"
IS_UBUNTU="no"

CODENAME=""

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

echo "Finding Debian/Ubuntu codename..."

CODENAME=`cat /etc/*-release | grep "VERSION="`

CODENAME=${CODENAME##*\(}
CODENAME=${CODENAME%%\)*}

if [ "x$CODENAME" = "x" ];then
  echo "Your Debian/ Ubuntu Version-codename could not be found, thus Passenger apt-repository won't be valid... exiting"
  echo "some example codenames: saucy, precise, lucid, wheezy, squeeze"
  exit 1
fi


$SUDO apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7

$SUDO $APT_GET install apt-transport-https

echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger $CODENAME main" > /etc/apt/sources.list.d/passenger.list

$SUDO chown root: /etc/apt/sources.list.d/passenger.list

$SUDO chmod 600 /etc/apt/sources.list.d/passenger.list

$SUDO $APT_GET update

INSTALLATION_DIR="/tmp/nginx_install"

if [ ! -d $INSTALLATION_DIR ];then
  echo "Creating installation directory..${INSTALLATION_DIR}"
  mkdir $INSTALLATION_DIR
fi
    

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


PROGRESSBAR=`grep "ruby-passenger" ~/.curlrc`

if [ "x$PROGRESSBAR" = "x" ];then
  echo "Setting up progress bar when downloading RVM / Rubies..."
  echo progress-bar >> ~/.curlrc
fi


SECUREPATH=`grep "rvmsudo_secure_path=1" ~/.profile`

if [ "x$SECUREPATH" = "x" ];then
  echo "Setting up rvmsudo_secure_path.."
  echo "export rvmsudo_secure_path=1" >> ~/.profile
fi

export rvmsudo_secure_path=1

NORI=`grep "gem: --no-ri" ~/.gemrc`

if [ "x$NORI" = "x" ];then
  echo "Making --no-ri --no-rdoc the default for gem install (will save disk space)"
  echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
fi


 
echo "After it is done installing, load RVM."
source ~/.rvm/scripts/rvm


echo "In order to work, RVM has some of its own dependancies that need to be installed..."

rvm requirements
RESULT=$?

if [ $RESULT -ne 0 ];then
  echo "error, can't continue, rvm is not detected. try rebooting your system"
  echo "close your tasks and type 'reboot' as toot"
  exit 1
fi

echo "Additional Dependencies:"
echo "For Ruby / Ruby HEAD (MRI, Rubinius, & REE), install the following..."

$RVMSUDO $APT_GET install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion libpq-dev


echo "adding Curl development headers with SSL support.."

# select $APT_GET install libcurl4-openssl-de or: 
$APT_GET install libcurl4-gnutls-dev

# echo "Once you are using RVM, installing Ruby is easy."

# $RVM install 1.9.3

# $RVM reload

# echo "Ruby is now installed. However, since we accessed it through a program that has a variety of Ruby versions, we need to tell the system to use 1.9.3 by default."

# $RVM use 1.9.3 --default

echo "The next step makes sure that we have all the required components of Ruby on Rails. We can continue to use RVM to install gems; type this line into terminal..."
rvm rubygems current

echo "Once everything is set up, it is time to install Rails..."

$RVM all do gem install rails --no-ri --no-rdoc

echo "Adding support for Sinatra, Rack and Bundler..."

$RVM all do gem install sinatra rack bundler --no-ri --no-rdoc


# echo "Once Ruby on Rails is installed, go ahead and install passenger..."

# $RVM all do gem install passenger --no-ri --no-rdoc

echo "Here is where Passenger really shines. As we are looking to install Rails on an nginx server, we only need to enter one more line into terminal.."

# for Apache2:
# $SUDO $APT_GET install libapache2-mod-passenger
# for NGINX:

$RVMSUDO $APT_GET install nginx-full passenger

# useless:

# $RVMSUDO passenger-install-nginx-module --auto --prefix=/usr \
# --nginx-source-dir=${INSTALLATION_DIR} \
# --extra-configure-flags="--conf-path=/etc/nginx/nginx.conf \
# --http-log-path=/var/log/nginx/access.log \
# --error-log-path=/var/log/nginx/error.log \
# --pid-path=/var/run/nginx.pid \
# --http-client-body-temp-path=/var/tmp/nginx/client \
#  --http-proxy-temp-path=/var/tmp/nginx/proxy \
# --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi \
# --with-md5-asm --with-md5=/usr/include --with-sha1-asm \
# --with-sha1=/usr/include \
# --with-http_fastcgi_module \
# --with-http_stub_status_module \
# --with-http_ssl_module \
# --add-module=${INSTALLATION_DIR}/`ls headers-more-nginx-module-* | head -1`"

echo "...And now Passenger takes over."

echo "The last step is to turn start nginx, as it does not do so automatically..."


NGINX_CONF="/etc/nginx/nginx.conf"

if [ -f $NGIX_CONF ];then
  
  echo "Uncommenting passenger_ruby and passenger_root directives at /etc/nginx/nginx.conf"
  cp -f $NGINX_CONF ${NGINX_CONF}.orig
  $SUDO sed -e "s/# passenger_root/passenger_root/g" $NGINX_CONF > $NGINX_CONF
  $SUDO sed -e "s/# passenger_ruby/passenger_ruby/g" $NGINX_CONF > $NGINX_CONF
fi

$SUDO service nginx start 

echo ""
echo ""
echo "Once you have rails installed, open up the nginx config file /opt/nginx/conf/nginx.conf"
echo ""
echo "type: sudo nano /opt/nginx/conf/nginx.conf"
echo ""
echo "write the text below, and save. Thats it"

echo "
server { 
  listen 80; 
  server_name example.com; 
  passenger_enabled on; 
  root /var/www/my_awesome_rails_app/public; 
}
"


echo "to create your new rails project, type: rails new my_awesome_rails_app"

