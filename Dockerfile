FROM ubuntu:trusty
MAINTAINER Dmitry Starodubtsev <dstarodubtsev@itrend.tv>

# Append ondrej/php-7.0 repository
RUN apt-get -y update && apt-get install -y --force-yes git software-properties-common python-software-properties
RUN apt-get install -y --force-yes language-pack-en-base
RUN apt-get autoremove -y --purge php5-*
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php-7.0
RUN apt-get -y update

# Install php7.0-fpm with needed extensions
RUN apt-get install -y --force-yes php7.0-fpm php7.0-cli php7.0-common php7.0-json php7.0-opcache \
    php7.0-phpdbg php7.0-dbg php7.0-gd php7.0-imap php7.0-ldap php7.0-pgsql php7.0-mysql \
    php7.0-pspell php7.0-recode php7.0-snmp php7.0-tidy php7.0-dev php7.0-intl php7.0-curl \
    nginx curl
RUN apt-get clean

# Install Composer
RUN curl -O https://getcomposer.org/installer
RUN php installer
RUN mv composer.phar /usr/local/bin/composer
RUN rm installer

# Install Redis
RUN git clone https://github.com/phpredis/phpredis.git
RUN cd phpredis && git checkout php7 && phpize && ./configure && make && make install
RUN rm -rf phpredis

# Append PHP redis-module
RUN echo "extension=redis.so" > /etc/php/mods-available/redis.ini
RUN ln -sf /etc/php/mods-available/redis.ini /etc/php/7.0/fpm/conf.d/20-redis.ini
RUN ln -sf /etc/php/mods-available/redis.ini /etc/php/7.0/cli/conf.d/20-redis.ini

ADD nginx_site /etc/nginx/sites-enabled/default
ADD server.crt /ssl/server.crt
ADD server.key /ssl/server.key
ADD index.php /www/index.php

ADD entry.sh /entry.sh
RUN chmod +x /entry.sh

EXPOSE 80 443

ENTRYPOINT ["/entry.sh"]
