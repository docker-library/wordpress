#!/bin/bash
set -e

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
        if [ -n "$MYSQL_PORT_3306_TCP" ]; then
                if [ -z "$OCTOBER_DB_HOST" ]; then
                        OCTOBER_DB_HOST='mysql'
                else
                        echo >&2 'warning: both OCTOBER_DB_HOST and MYSQL_PORT_3306_TCP found'
                        echo >&2 "  Connecting to OCTOBER_DB_HOST ($OCTOBER_DB_HOST)"
                        echo >&2 '  instead of the linked mysql container'
                fi
        fi

        if [ -z "$OCTOBER_DB_HOST" ]; then
                echo >&2 'error: missing OCTOBER_DB_HOST and MYSQL_PORT_3306_TCP environment variables'
                echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
                echo >&2 '  with -e OCTOBER_DB_HOST=hostname:port?'
                exit 1
        fi

        # if we're linked to MySQL, and we're using the root user, and our linked
        # container has a default "root" password set up and passed through... :)
        : ${OCTOBER_DB_USER:=root}
        if [ "$OCTOBER_DB_USER" = 'root' ]; then
                : ${OCTOBER_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
        fi
        : ${OCTOBER_DB_NAME:=october}

        if [ -z "$OCTOBER_DB_PASSWORD" ]; then
                echo >&2 'error: missing required OCTOBER_DB_PASSWORD environment variable'
                echo >&2 '  Did you forget to -e OCTOBER_DB_PASSWORD=... ?'
                echo >&2
                echo >&2 '  (Also of interest might be OCTOBER_DB_USER and OCTOBER_DB_NAME.)'
                exit 1
        fi
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

TERM=dumb php -- "$OCTOBER_DB_HOST" "$OCTOBER_DB_USER" "$OCTOBER_DB_PASSWORD" "$OCTOBER_DB_NAME" <<'EOPHP'
<?php
// database might not exist, so let's try creating it (just to be safe)
$stderr = fopen('php://stderr', 'w');
list($host, $port) = explode(':', $argv[1], 2);
$maxTries = 10;

do {
$mysql = new mysqli(getenv('MYSQL_PORT_3306_TCP_ADDR'), 'root', getenv('MYSQL_ENV_MYSQL_ROOT_PASSWORD'), '', (int)getenv('MYSQL_PORT_3306_TCP_PORT'));
if ($mysql->connect_error) {
        fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
        --$maxTries;
        if ($maxTries <= 0) {
                exit(1);
        }
        sleep(3);
}
} while ($mysql->connect_error);
if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `october_cms`')) {
fwrite($stderr, "\n" . 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
$mysql->close();
exit(1);
}
$mysql->close();
EOPHP

php artisan october:up

chown -R www-data:www-data /var/www/html

exec "$@"
