# Supported tags and respective `Dockerfile` links
- `7.0-apache` ([php7.0/apache/Dockerfile](https://github.com/Dragontek/octobercms/blob/master/7.0/apache/Dockerfile))
- `7.0-fpm` ([php7.0/fpm/Dockerfile](https://github.com/Dragontek/octobercms/blob/master/7.0/fpm/Dockerfile))
- `7.1-apache` ([php7.1/fpm/Dockerfile](https://github.com/Dragontek/octobercms/blob/master/7.1/apache/Dockerfile))
- `7.1-fpm` ([php7.1/fpm/Dockerfile](https://github.com/Dragontek/octobercms/blob/master/7.1/fpm/Dockerfile))
- `latest`, `7.2apache` ([php7.1/apache/Dockerfile](https://github.com/Dragontek/octobercms/blob/master/7.1/apache/Dockerfile))

# About this Repo

This automated build is based on the official Wordpress automated build image, and supports similar tags.

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
Basic Example `docker-compose.yml` for `dragontek/octobercms`:
```
version: '2'
services:
  web:
    image: "dragontek/octobercms"
    ports:
     - "8080:80"
  mysql:
    image: "mariadb"
    environment:
     - MYSQL_ROOT_PASSWORD=example
  memcached:
    image: "memcached"
```


Advanced Example `docker-compose.yml` for `dragontek/octobercms`:
```
version: '2'
services:
  web:
    image: "dragontek/octobercms"
    ports:
     - "8080:80"
    depends_on:
     - postgres
     - memcached
     - redis
    environment:
     - GIT_HOSTS=gitlab.com
     - GIT_THEMES=git@gitlab.com:path/mytheme.git
     - OCTOBER_CMS_ACTIVE_THEME=mytheme
     - OCTOBER_PLUGINS=October.Drivers;RainLab.GoogleAnalytics;
     - OCTOBER_DB_DRIVER=pgsql
     - OCTOBER_DB_HOST=postgres
     - OCTOBER_DB_PASSWORD=example
     - OCTOBER_CACHE_DEFAULT=memcached
     - OCTOBER_SESSION_DRIVER=redis
    volumes:
     - ~/.ssh/id_rsa:/root/.ssh/id_rsa
  postgres:
    image: "postgres"
    environment:
     - POSTGRES_PASSWORD=example
  memcached:
    image: "memcached"
  redis:
    image: "redis"
```

## Database Environment Variables
The following environment variables are honored for configuring your October instance:
* `-e OCTOBER_DB_DRIVER=...` (defaults to appropriate driver for linked database container. Must be specified as either 'mysql' or 'pgsql' for external database.  May be set to 'none' for no database)
* `-e OCTOBER_DB_HOST=...` (defaults to the IP of the linked database container)
* `-e OCTOBER_DB_PASSWORD=...` (defaults to the password for the user of the linked database container)
* `-e OCTOBER_DB_NAME=...` (defaults to `october_cms`)

## October Themes and Plugins
Themes and/or plugins can be installed from the marketplace with the following environment variables:
* `-e OCTOBER_THEMES=...` (defaults to null)
* `-e OCTOBER_PLUGINS=...` (defaults to null)

Use semicolon separated list for multiple themes or plugins (e.g. `-e OCTOBER_PLUGINS="RainLab.Blog;RainLab.GoogleAnalytics"`)

## Git Themes and Plugins
Themes and/or plugins can be installed from the git repositories with the following environment variables:
* `-e GIT_HOSTS=...` (defaults to null, used to add git servers to /root/.ssh/known_hosts, only needed for ssh)
* `-e GIT_THEMES=...` (defaults to null)
* `-e GIT_PLUGINS=...` (defaults to null)

Use semicolon separated list for multiple themes or plugins (e.g. `-e GIT_THEMES="git@gitlab.com:path/repo.git"`)

If you use a private repository, then you should map your private key to the container (e.g `-v ~/.ssh/id_rsa:/root/.ssh/id_rsa`)

Another solution is to get an "Personal Access Token" from your repository provider and use https instead (e.g. `-e GIT_THEMES="https://username:token@gitlab.com:path/repo.git"`)

Please note that for Plugins, it will determine namespace based on your repository path (e.g `git@gitlab.com:mycompany/blog.git` will clone into `/plugins/mycompany/blog`)

## Other Environment Variables
Most of the configuration settings can be set through environment variables.  The format always starts with `OCTOBER_` and then the configuration file name (e.g. `APP_`), and then the property name (e.g. `DEBUG`).  Property names that are camel case are split by the underscore, as are any sub properties.  Please refer to the configuration files for more detailed explanations and for valid settings.

### APP settings
* `-e OCTOBER_APP_DEBUG=...` (defaults to `false`)
* `-e OCTOBER_APP_URL=...` (defaults to `'http://localhost'`)
* `-e OCTOBER_APP_TIMEZONE=...` (defaults to `'UTC'`)
* `-e OCTOBER_APP_LOCALE=...` (defaults to `'en'`)
* `-e OCTOBER_APP_KEY=...` (defaults to randomly generated 32 bit key)
* `-e OCTOBER_APP_CIPHER=...` (defaults to `'AES-256-CBC'`)
* `-e OCTOBER_APP_LOG=...` (defaults to `'single'`)

### CMS settings
* `-e OCTOBER_CMS_EDGE_UPDATES=...` (defaults to `false`)
* `-e OCTOBER_CMS_ACTIVE_THEME=...` (defaults to `'demo'`)
* `-e OCTOBER_CMS_BACKEND_URI=...` (defaults to `'backend'`)
* `-e OCTOBER_CMS_DISABLE_CORE_UPDATES=...` (defaults to `false`)
* `-e OCTOBER_CMS_ENABLE_ROUTES_CACHE=...` (defaults to `false`)
* `-e OCTOBER_CMS_URL_CACHE_TTL=...` (defaults to `10`)
* `-e OCTOBER_CMS_PARSED_PAGE_CACHE_TTL=...` (defaults to `10`)
* `-e OCTOBER_CMS_ENABLE_ASSET_CACHE=...` (defaults to `false`)
* `-e OCTOBER_CMS_ENABLE_ASSET_MINIFY=...` (defaults to `null`)
* `-e OCTOBER_CMS_STORAGE_UPLOADS_DISK=...` (defaults to `'local'`)
* `-e OCTOBER_CMS_STORAGE_UPLOADS_PATH=...` (defaults to `'/storage/app/uploads'`)
* `-e OCTOBER_CMS_STORAGE_UPLOADS_FOLDER=...` (defaults to `'uploads'`)
* `-e OCTOBER_CMS_STORAGE_MEDIA_DISK=...` (defaults to `'local'`)
* `-e OCTOBER_CMS_STORAGE_MEDIA_PATH=...` (defaults to `'/storage/app/media'`)
* `-e OCTOBER_CMS_STORAGE_MEDIA_FOLDER=...` (defaults to `'media'`)
* `-e OCTOBER_CMS_CONVERT_LINE_ENDINGS=...` (defaults to `false`)
* `-e OCTOBER_CMS_LINK_POLICY=...` (defaults to `'detect'`)
* `-e OCTOBER_CMS_ENABLE_CSRF_PROTECTION=...` (defaults to `false`)

### FILESYSTEMS settings
* `-e OCTOBER_FILESYSTEMS_DEFAULT=...` (defaults to `'local'`)
* `-e OCTOBER_FILESYSTEMS_CLOUD=...` (defaults to `'s3'`)
* `-e OCTOBER_FILESYSTEMS_DISKS_S3_KEY=...` (defaults to `'your-key'`)
* `-e OCTOBER_FILESYSTEMS_DISKS_S3_SECRET=...` (defaults to `'your-secret'`)
* `-e OCTOBER_FILESYSTEMS_DISKS_S3_REGION=...` (defaults to `'your-region'`)
* `-e OCTOBER_FILESYSTEMS_DISKS_S3_BUCKET=...` (defaults to `'your-bucket'`)
* `-e OCTOBER_FILESYSTEMS_DISKS_RACKSPACE_KEY=...` (defaults to `'your-key'`)
* `-e OCTOBER_FILESYSTEMS_DISKS_RACKSPACE_USERNAME=...` (defaults to `'your-username'`)
* `-e OCTOBER_FILESYSTEMS_DISKS_RACKSPACE_CONTAINER=...` (defaults to `'your-container'`)

### MAIL settings
* `-e OCTOBER_MAIL_DRIVER=...` (defaults to `'mail'`)
* `-e OCTOBER_MAIL_HOST=...` (defaults to `'smtp.mailgun.org'`)
* `-e OCTOBER_MAIL_PORT=...` (defaults to `587`)
* `-e OCTOBER_MAIL_FROM_ADDRESS=...` (defaults to `'noreply@domain.tld'`)
* `-e OCTOBER_MAIL_FROM_NAME=...` (defaults to `'OctoberCMS'`)
* `-e OCTOBER_MAIL_ENCRYPTION=...` (defaults to `'tls'`)
* `-e OCTOBER_MAIL_USERNAME=...` (defaults to `null`)
* `-e OCTOBER_MAIL_PASSWORD=...` (defaults to `null`)
* `-e OCTOBER_MAIL_PRETEND=...` (defaults to `false`)

### SERVICES settings
* `-e OCTOBER_SERVICES_MAILGUN_DOMAIN=...` (defaults to `''`)
* `-e OCTOBER_SERVICES_MAILGUN_SECRET=...` (defaults to `''`)
* `-e OCTOBER_SERVICES_MANDRILL_SECRET=...` (defaults to `''`)
* `-e OCTOBER_SERVICES_SES_KEY=...` (defaults to `''`)
* `-e OCTOBER_SERVICES_SES_SECRET=...` (defaults to `''`)
* `-e OCTOBER_SERVICES_SES_REGION=...` (defaults to `'us-east-1'`)
* `-e OCTOBER_SERVICES_STRIPE_MODEL=...` (defaults to `'User'`)
* `-e OCTOBER_SERVICES_STRIPE_SECRET=...` (defaults to `''`)

### SESSION settings
* `-e OCTOBER_SESSION_DRIVER=...` (defaults to `'file'`)
* `-e OCTOBER_SESSION_LIFETIME=...` (defaults to `120`)
* `-e OCTOBER_SESSION_ENCRYPT=...` (defaults to `false`)
* `-e OCTOBER_SESSION_CONNECTION=...` (defaults to `null`)
* `-e OCTOBER_SESSION_TABLE=...` (defaults to `'sessions'`)
* `-e OCTOBER_SESSION_COOKIE=...` (defaults to `'october_session'`)
* `-e OCTOBER_SESSION_PATH=...` (defaults to `'/'`)
* `-e OCTOBER_SESSION_DOMAIN=...` (defaults to `null`)
* `-e OCTOBER_SESSION_SECURE=...` (defaults to `false`)

## Notes
Work on this image is ongoing, and I intend to support more environment variables to allow the user to configure more of their October instance.

Please let me know what else you'd like to see.
