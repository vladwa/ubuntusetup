#!/bin/bash

#
# UPDATE / UPGRADE
#

echo "--------------- Update + Upgrade";

sudo apt-get update;
sudo apt-get -y upgrade;

#
#  INSTALL
#

echo "--------------- Installing Tools";

PHP7_PPA="ondrej/php"
if ! grep -q "$PHP7_PPA" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    sudo add-apt-repository ppa:$PHP7_PPA;
    sudo apt-get update;
fi

apt_get_packages=( "git" "mcrypt" "php7.0" "php7.0-dev" "php7.0-fpm" "php7.0-mysql" "php7.0-cli" "php7.0-common" "php7.0-json" "php7.0-curl" "php7.0-mcrypt" "php7.0-readline" "php-memcached" "php-mongodb" "php-redis" ); # "python-pip"
# php7.0 php7.0-fpm php7.0-mysql php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-json php7.0-mcrypt php7.0-readline
# api: php5-memcached php5-mongo php5-redis 
for i in "${!apt_get_packages[@]}"; do
    if [ $(dpkg-query -W -f='${Status}' "${apt_get_packages[$i]}" 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo "--------------- Installing ${apt_get_packages[$i]}";
        sudo apt-get install -y ${apt_get_packages[$i]};
    else
        echo "--------------- '${apt_get_packages[$i]}' already installed";
    fi
done;

# nginx 1.9.10
NGINX_PPA="nginx"
if ! grep -q "$NGINX_PPA" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    sudo apt-get -y purge nginx*;
    sudo apt-get -y autoremove;
    sudo rm /etc/apt/sources.list.d/nginx.list;
    wget -q -O- http://nginx.org/keys/nginx_signing.key | sudo apt-key add -;
    sudo bash -c "echo '
deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx' >> /etc/apt/sources.list.d/nginx.list;"
    sudo apt-get update && sudo apt-get install -y nginx;
fi

# composer
if [ ! -f /usr/local/bin/composer ]; then
    echo "--------------- Installing Composer";
    curl -sS https://getcomposer.org/installer | php;
    sudo mv composer.phar /usr/local/bin/composer;
else
    echo "--------------- Updating Composer";
    sudo composer self-update;
fi

if [ $(cat ~/.bashrc | grep -c "mybash") -eq 0 ];
then

echo '

alias reload="sudo service nginx reload"
alias restart="sudo service nginx restart"
alias restartphp="sudo service php7-fpm restart"
alias restartsql="sudo service mysql restart"

alias hosts="sudo vi /etc/hosts"
alias phpini="sudo vi /etc/php5/fpm/php.ini"
alias mybash="vi ~/.bashrc"

alias vhosts="cd /etc/nginx/conf.d; ls -li"
alias www="cd /var/www; ls -li"

alias ..="cd .."
alias ...="cd ../.."

' >> ~/.bashrc;
	exec bash;
fi