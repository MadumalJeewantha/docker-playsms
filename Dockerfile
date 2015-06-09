FROM ubuntu:trusty

MAINTAINER Anton Raharja <antonrd@gmail.com>

# dbs
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
	apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt php5-gd php5-imap php5-curl

# apache2
ADD start-apache2.sh /start-apache2.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN a2enmod rewrite

# mysql
ADD start-mysqld.sh /start-mysqld.sh
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
RUN rm -rf /var/lib/mysql/*

# Add image configuration and scripts

# playsms
ADD start-playsmsd.sh /start-playsmsd.sh
ADD supervisord-playsmsd.conf /etc/supervisor/conf.d/supervisord-playsmsd.conf
ADD install.conf /app/install.conf
ADD install.sh /install.sh
RUN rm -rf /app && mkdir /app && git clone --branch 1.0 --depth=1 https://github.com/antonraharja/playSMS.git /app

# scripts
ADD run.sh /run.sh
RUN chmod +x /*.sh

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
