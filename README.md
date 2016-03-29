# About this Repo

This automated build is based on the official Wordpress automated build image, and supports the same tags.

## Quickstart
If you'd like to get up and running quickly, this image can be run without any linked containers.
```
$ docker run --name some-october -p 8080:80 -d dragontek/octobercms
```

This will start the container up and initialize a local SQLite instance for the database, and you can visit the site by going to http://localhost:8080. The default username and password for the backend are both 'admin'.

October provides a great interface for modifying files directly through the backend, and for many tasks, such as theme development, this may be sufficient.  When you're finished, you can simply use the theme export feature.  Just remember not to remove the docker container, or you will lose your changes.

The image also exposes the `/var/www/html` folder, so if you would like to use a local editor, you can mount that volume to your local machine:
```
$ docker run --name some-october -p 8080:80 -v $(pwd):/var/www/html -d dragontek/octobercms
```

This will start the container and copy full website to the current directory.  This is a better option for tasks such as plugin development.

## Database Support
The examples so far have used a local SQLite instance, but for production you will probably want to use either MySQL/MariaDB or Postgres.  This image supports linking of both database engines.
```
$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=example -d mariadb
$ docker run --name some-october --link some-mysql:mysql -d dragontek/octobercms
```
or
```
$ docker run --name some-postgres -e POSTGRES_PASSWORD=example -d postgres
$ docker run --name some-october --link some-postgres:postgres -d dragontek/octobercms
```
These commands will start up the database, link the containers and configure October to use the appropriate database.

## ... via `docker-compose`
Example `docker-compose.yml` for `dragontek/octobercms`:

```
october:
  image: dragontek/octobercms
  links:
    - db:mysql
  ports:
    - 8080:80

db:
  image: mariadb
  environment:
    MYSQL_ROOT_PASSWORD: example
```
Alternatively, you can specify an external database with environment variables (see below).

## Environment Variables
The following environment variables are honored for configuring your October instance: 
* `-e OCTOBER_DB_DRIVER=...` (defaults to appropriate driver for linked database container, must be specified as either 'mysql' or 'pgsql' for external database)
* `-e OCTOBER_DB_HOST=...` (defaults to the IP of the linked database container)
* `-e OCTOBER_DB_USER=...` (defaults to the database user ('root' or 'postgres') of the linked database container)
* `-e OCTOBER_DB_PASSWORD=...` (defaults to the password for the user of the linked database container)
* `-e OCTOBER_DB_NAME=...` (defaults to "october_cms")

....More coming soon!

## Notes
Work on this image is ongoing, and I intend to support more environment variables to allow the user to configure more of their October instance.  Some things on my list include:

* Support for enabling/disabling 'dev'
* Support for configuring Redis
* Support for configuring various file systems such as AWS (to allow HA/scalability)
* Support for automating the installation of plugins and themes (again for HA)

Please let me know what else you'd like to see.
