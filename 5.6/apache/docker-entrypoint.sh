#!/bin/bash
set -e

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then

        # Copy files to the web directory if they don't exist already
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

        # Generate random key for laravel if it's not specified
        php artisan key:generate

        # Make sure we have the right permissions
        if [ -f /root/.ssh/id_rsa ]; then
          chmod 0600 /root/.ssh/id_rsa
        fi

        # Add git host keys to known hosts
        IFS=';' read -ra KEY <<< "$GIT_HOSTS"
        for i in "${KEY[@]}"; do
            ssh-keyscan -H $i >> /root/.ssh/known_hosts
        done

        # Install git themes if they are identified
        IFS=';' read -ra THEME <<< "$GIT_THEMES"
        for i in "${THEME[@]}"; do
          basename=$(basename $i)
          repo=${basename%.*}
          # Only clone if it doesn't already exist
          if ! [ -e themes/$repo ]; then
            (cd themes && git clone $i)
          fi
        done

        # Install git plugins if they are identified
        IFS=';' read -ra PLUGIN <<< "$GIT_PLUGINS"
        for i in "${PLUGIN[@]}"; do
          url_without_suffix="${i%.*}"
          reponame="$(basename "${url_without_suffix}")"
          hostname="$(basename "${url_without_suffix%/${reponame}}")"
          namespace="${hostname##*:}"
          # Only clone if it doesn't already exist
          if ! [ -e plugins/$namespace/$reponame ]; then
            (cd plugins && git clone $i $namespace/$reponame)
          fi
        done

        # If we don't need a database we can bail here
        if [ "$OCTOBER_DB_DRIVER" == 'none' ] ; then
          echo >&2 'Notice! Database has been disabled.'
          exec "$@"
        fi

        # WARNING: Linked environment variables are depreciated and only work in docker-compose v1
        if [ -n "$MYSQL_PORT_3306_TCP" ]; then
                if [ -z "$OCTOBER_DB_HOST" ]; then
                        OCTOBER_DB_HOST=$MYSQL_PORT_3306_TCP_ADDR
                else
                        echo >&2 'warning: both OCTOBER_DB_HOST and MYSQL_PORT_3306_TCP found'
                        echo >&2 "  Connecting to OCTOBER_DB_HOST ($OCTOBER_DB_HOST)"
                        echo >&2 '  instead of the linked mysql container'
                fi
                OCTOBER_DB_DRIVER='mysql'
        fi
        
        # WARNING: Linked environment variables are depreciated and only work in docker-compose v1
        if [ -n "$POSTGRES_PORT_5432_TCP" ]; then
                if [ -z "$OCTOBER_DB_HOST" ]; then
                        OCTOBER_DB_HOST=$POSTGRES_PORT_5432_TCP_ADDR
                else
                        echo >&2 'warning: both OCTOBER_DB_HOST and POSTGRES_PORT_5432_TCP found'
                        echo >&2 "  Connecting to OCTOBER_DB_HOST ($OCTOBER_DB_HOST)"
                        echo >&2 '  instead of the linked postgres container'
                fi
                OCTOBER_DB_DRIVER='pgsql'
        fi

        # Set default database port if not already set by environment
        if [ "$OCTOBER_DB_DRIVER" == 'mysql' ] ; then
          : ${OCTOBER_DB_PORT:=${MYSQL_PORT_3306_TCP_PORT:-3306}}
        fi

        if [ "$OCTOBER_DB_DRIVER" == 'pgsql' ] ; then
          : ${OCTOBER_DB_PORT:=${POSTGRES_PORT_5432_TCP_PORT:-5432}}
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
          exit 1
        fi

        
TERM=dumb php -- "$OCTOBER_DB_DRIVER" "$OCTOBER_DB_HOST" "$OCTOBER_DB_PORT" "$OCTOBER_DB_PASSWORD" "$OCTOBER_DB_NAME" <<'EOPHP'
<?php
$driver = $argv[1];
$host = $argv[2];
$port = $argv[3];
$dbpass = $argv[4];
$dbname = $argv[5];

$retries = 10;

switch($driver) {
  case 'mysql':
    while ($retries > 0)
    {
      try {
        $pdo = new PDO("mysql:host=$host;port=$port", 'root', $dbpass);
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
        $pdo = new PDO("pgsql:host=$host;port=$port", 'postgres', $dbpass);
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
export OCTOBER_DB_DRIVER OCTOBER_DB_HOST OCTOBER_DB_PORT OCTOBER_DB_PASSWORD OCTOBER_DB_NAME

# Bring up the initial OctoberCMS database
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

# Pull latest code from all plugin and theme git repos
php artisan october:util git pull

# Update OctoberCMS to the latest version
php artisan october:update

chown -R www-data:www-data /var/www/html

fi

exec "$@"
