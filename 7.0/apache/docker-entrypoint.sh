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
                : ${OCTOBER_DB_PORT:=${MYSQL_PORT_3306_TCP_PORT:-3306}}
                # if we're linked to MySQL, and we're using the root user, and our linked
                # container has a default "root" password set up and passed through... :)
                : ${OCTOBER_DB_USER:=${MYSQL_ENV_MYSQL_USER:-root}}
                if [ "$OCTOBER_DB_USER" = 'root' ]; then
                		: ${OCTOBER_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
                fi

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
                : ${OCTOBER_DB_PORT:=${POSTGRES_PORT_5432_TCP_PORT:-5432}}
                # if we're linked to Postgres, get the user-configured username or default 'postgres'
                : ${OCTOBER_DB_USER:=${POSTGRES_ENV_POSTGRES_USER:-postgres}}
                : ${OCTOBER_DB_PASSWORD:=$POSTGRES_ENV_POSTGRES_PASSWORD}

        fi

        # Set default database name if not already set by environment
        : ${OCTOBER_DB_NAME:=october_cms}

        if [ -z "$OCTOBER_DB_HOST" ]; then
          # Check to ensure we've got DB HOST, otherwise we'll use sqlite
          echo >&2 'warning: missing OCTOBER_DB_HOST, MYSQL_PORT_3306_TCP and POSTGRES_PORT_5432_TCP environment variables'
          echo >&2 '  Did you forget to --link some_db_container:db or set an external db'
          echo >&2 '  with -e OCTOBER_DB_HOST=hostname:port?'
          echo >&2 '===================='
          echo >&2 'Using sqlite instead'
          #exit 1
        elif [ -z "$OCTOBER_DB_PASSWORD" ]; then
          # We have a DB HOST defined, so we're not using sqlite, but no password found
          echo >&2 'error: missing required OCTOBER_DB_PASSWORD environment variable'
          echo >&2 '  Did you forget to -e OCTOBER_DB_PASSWORD=... ?'
          echo >&2
          echo >&2 '  (Also of interest might be OCTOBER_DB_USER and OCTOBER_DB_NAME.)'
          exit 1
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

        # if we have a clean repo then install
        if ! [ -d vendor ]; then
          composer install
        fi
        
        # Generate random key for this container if it's not specified
        if [ -n "$OCTOBER_KEY" ]; then
          export OCTOBER_KEY = "$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
        fi

TERM=dumb php -- "$OCTOBER_DB_HOST" "$OCTOBER_DB_PORT" "$OCTOBER_DB_USER" "$OCTOBER_DB_PASSWORD" "$OCTOBER_DB_NAME" <<'EOPHP'
<?php
$host = $argv[1];
$port = $argv[2];
$dbuser = $argv[3];
$dbpass = $argv[4];
$dbname = $argv[5];

$retries = 10;

switch(getenv('OCTOBER_DB_DRIVER')) {
  case 'mysql':
    while ($retries > 0)
    {
      try {
        $pdo = new PDO("mysql:host=$host;port=$port", $dbuser, $dbpass);
        $pdo->query("CREATE DATABASE IF NOT EXISTS $dbname");
        $retries = 0;
      } catch (PDOException $e) {
        $retries--;
        sleep(3);
      }
    }
    break;
  case 'pgsql':
    while ($retries > 0)
    {
      try {
        $pdo = new PDO("pgsql:host=$host;port=$port", $dbuser, $dbpass);
        // Postgres version of "CREATE DATABASE IF NOT EXISTS"
        $res = $pdo->query("select count(*) from pg_catalog.pg_database where datname = '$dbname';");
        if($res->fetchColumn() < 1)
          $pdo->query("CREATE DATABASE $dbname");

        $retries = 0;
      } catch (PDOException $e) {
        $retries--;
        sleep(3);
      }
    }
    break;
  default:
    $pdo = new PDO("sqlite:storage/database.sqlite");
    break;
}
EOPHP

# Export the variables so we can use them in config files
export OCTOBER_DB_HOST OCTOBER_DB_PORT OCTOBER_DB_USER OCTOBER_DB_PASSWORD OCTOBER_DB_NAME

php artisan october:up

# Install plugins if they are identified
IFS=';' read -ra PLUGIN <<< "$OCTOBER_PLUGINS"
for i in "${PLUGIN[@]}"; do
    php artisan plugin:install $i
done

# Install themes if they are identified
IFS=';' read -ra THEME <<< "$OCTOBER_THEMES"
for i in "${THEME[@]}"; do
    php artisan theme:install $i
done

chown -R www-data:www-data /var/www/html

fi

exec "$@"
