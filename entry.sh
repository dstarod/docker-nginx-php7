#!/usr/bin/env bash

# Add access to global environment vars

function setEnvironmentVariable() {
    if [ -z "$2" ]; then
        return
    fi
    if grep -q $1 /etc/php/7.0/fpm/pool.d/www.conf; then
        sed -i "s/^env\[$1.*/env[$1] = $2/g" /etc/php/7.0/fpm/pool.d/www.conf
    else
        echo "env[$1] = $2" >> /etc/php/7.0/fpm/pool.d/www.conf
    fi
}

for _curVar in `env | awk -F = '{print $1}'`;do
    setEnvironmentVariable ${_curVar} ${!_curVar}
done

# Start php-fpm and nginx
service php7.0-fpm start
nginx -g "daemon off;"
