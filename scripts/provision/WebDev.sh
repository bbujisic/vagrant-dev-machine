#!/bin/bash

# Variables
APPENV=local
DBHOST=localhost
DBNAME=db
DBUSER=root
DBPASSWD=root
DBDUMP="/var/www/html/db.sql"

#  > /dev/null 2>&1

echo -e "\n--- Provisioning virtual machine. Go get a coffee, this will take a while ---\n"

mkdir -p /var/www
sudo apt-get update > /dev/null 2>&1

echo -e "\n--- Downloading and setting up LAMP stack ---\n"

# This is needed in order for pecl uploadprogress to be installed.
sudo apt-get install -y build-essential curl > /dev/null 2>&1
sudo apt-get install -y python-software-properties > /dev/null 2>&1
sudo add-apt-repository -y ppa:brianmercer/php5-xhprof > /dev/null 2>&1
sudo add-apt-repository -y ppa:brightbox/ruby-ng > /dev/null 2>&1
sudo add-apt-repository -y ppa:chris-lea/node.js > /dev/null 2>&1
sudo apt-get update > /dev/null 2>&1
sudo add-apt-repository -y ppa:ondrej/php5-5.6 > /dev/null 2>&1
sudo apt-get update > /dev/null 2>&1

echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
apt-get -y install mysql-server-5.5 mysql-common mysql-client > /dev/null 2>&1

sudo apt-get install -y apache2 > /dev/null 2>&1
sudo apt-get install -y php5 libapache2-mod-php5 php5-mhash php5-mcrypt php5-curl php5-cli php5-mysql php5-gd php5-intl php5-xsl > /dev/null 2>&1
sudo apt-get install -y php-pear php5-dev php5-memcache php-apc php5-xdebug graphviz > /dev/null 2>&1

echo -e "\n--- Downloading and setting up Git ---\n"
sudo apt-get install -y git > /dev/null 2>&1

echo -e "\n--- Downloading and setting up PhpMyAdmin ---\n"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
sudo apt-get install -y phpmyadmin > /dev/null 2>&1

echo -e "\n--- Downloading and setting up Memcache ---\n"
sudo aptitude install -y memcached > /dev/null 2>&1
pecl install -y memcached > /dev/null 2>&1

echo -e "\n--- Downloading and setting up UploadProgress ---\n"
sudo pecl install -Z uploadprogress > /dev/null 2>&1

echo -e "\n--- Creating MySQL root user and db. ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"
if [ -f "$DBDUMP" ]
then
    echo -e "\n--- Importing provided database dump. ---\n"
    mysql -uroot -p$DBPASSWD $DBNAME < $DBDUMP
fi

echo -e "\n--- Installing Composer and Drush ---\n"
php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === 'fd26ce67e3b237fffd5e5544b45b0d92c41a4afe3e3f778e942e43ce6be197b9cdc7c251dcde6e2a52297ea269370680') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); }"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

wget http://files.drush.org/drush.phar
php drush.phar core-status
chmod +x drush.phar
sudo mv drush.phar /usr/local/bin/drush
drush init

echo -e "\n--- Finalizing setup ---\n"
sudo apt-get upgrade > /dev/null 2>&1
echo "short_open_tag = On" >> /etc/php5/apache2/php.ini
echo "display_errors = On" >> /etc/php5/apache2/php.ini
echo "display_startup_errors = On" >> /etc/php5/apache2/php.ini
echo "error_log = '/var/log/php-errors.log'" >> /etc/php5/apache2/php.ini
echo "max_execution_time = 90" >> /etc/php5/apache2/php.ini
echo "post_max_size = 1024M" >> /etc/php5/apache2/php.ini
echo "upload_max_filesize = 1024M" >> /etc/php5/apache2/php.ini
echo "extension=memcache.so" >> /etc/php5/apache2/php.ini
echo "extension=uploadprogress.so" >> /etc/php5/apache2/php.ini

# @todo:  /etc/php5/conf.d/xdebug.ini: No such file or directory
echo "xdebug.remote_enable = 1" >> /etc/php5/conf.d/xdebug.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php5/conf.d/xdebug.ini

echo "<Directory /var/www/html>" >> /etc/apache2/apache2.conf
echo "  Options -Indexes +FollowSymLinks" >> /etc/apache2/apache2.conf
echo "  AllowOverride All" >> /etc/apache2/apache2.conf
echo "</Directory>" >> /etc/apache2/apache2.conf

sudo a2enmod rewrite



service apache2 restart