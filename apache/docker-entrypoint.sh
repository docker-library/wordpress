#!/bin/bash
set -e

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then

        if [ -n "$MYSQL_PORT_3306_TCP" ]; then
                if [ -z "$OCTOBER_DB_HOST" ]; then
                        OCTOBER_DB_HOST=$MYSQL_PORT_3306_TCP_ADDR
                else
                        echo >&2 'warning: both OCTOBER_DB_HOST and MYSQL_PORT_3306_TCP found'
                        echo >&2 "  Connecting to OCTOBER_DB_HOST ($OCTOBER_DB_HOST)"
                        echo >&2 '  instead of the linked mysql container'
                fi
                export OCTOBER_DB_DRIVER='mysql'
        fi
        if [ -n "$POSTGRES_PORT_5432_TCP" ]; then
                if [ -z "$OCTOBER_DB_HOST" ]; then
                        OCTOBER_DB_HOST=$POSTGRES_PORT_5432_TCP_ADDR
                else
                        echo >&2 'warning: both OCTOBER_DB_HOST and POSTGRES_PORT_5432_TCP found'
                        echo >&2 "  Connecting to OCTOBER_DB_HOST ($OCTOBER_DB_HOST)"
                        echo >&2 '  instead of the linked postgres container'
                fi
                export OCTOBER_DB_DRIVER='pgsql'
        fi
        if [ -z "$OCTOBER_DB_HOST" ]; then
                echo >&2 'warning: missing OCTOBER_DB_HOST, MYSQL_PORT_3306_TCP and POSTGRES_PORT_5432_TCP environment variables'
                echo >&2 '  Did you forget to --link some_db_container:db or set an external db'
                echo >&2 '  with -e OCTOBER_DB_HOST=hostname:port?'
                #exit 1
        fi

        # if we're linked to MySQL, and we're using the root user, and our linked
        # container has a default "root" password set up and passed through... :)
        : ${OCTOBER_DB_USER:=${MYSQL_ENV_MYSQL_USER:-postgres}}
        : ${OCTOBER_DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD:-$POSTGRES_ENV_POSTGRES_PASSWORD}}

        : ${OCTOBER_DB_NAME:=october}

        if [ -z "$OCTOBER_DB_PASSWORD" ]; then
                echo >&2 'warning: missing required OCTOBER_DB_PASSWORD environment variable'
                echo >&2 '  Did you forget to -e OCTOBER_DB_PASSWORD=... ?'
                echo >&2
                echo >&2 '  (Also of interest might be OCTOBER_DB_USER and OCTOBER_DB_NAME.)'
                #exit 1
        fi
        if ! [ -e index.php ]; then
                echo >&2 "OctoberCMS not found in $(pwd) - copying now..."
                if [ "$(ls -A)" ]; then
                        echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
                        ( set -x; ls -A; sleep 10 )
                fi
                tar cf - --one-file-system -C /usr/src/october . | tar xf -
                echo >&2 "Complete! OctoberCMS has been successfully copied to $(pwd)"
        fi

TERM=dumb php -- "$OCTOBER_DB_HOST" "$OCTOBER_DB_PORT" "$OCTOBER_DB_USER" "$OCTOBER_DB_PASSWORD" "$OCTOBER_DB_NAME" <<'EOPHP'
<?php
$host = $argv[1];
$port = $argv[2];
$dbuser = $argv[3];
$dbpass = $argv[4];
$dbname = $argv[5];

$driver = getenv('OCTOBER_DB_DRIVER');


// database might not exist, so let's try creating it (just to be safe)
if(null !== $host) {

} else {
  $dbh = new PDO("sqlite:storage/database.sqlite");
}
EOPHP
php artisan october:up

chown -R www-data:www-data /var/www/html

fi

exec "$@"
