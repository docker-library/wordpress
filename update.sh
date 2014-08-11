#!/bin/bash
set -e

current="$(curl -sSL 'http://api.wordpress.org/core/version-check/1.7/' | sed -r 's/^.*"current":"([^"]+)".*$/\1/')"

sed -ri 's/^(ENV WORDPRESS_VERSION ).*/\1'"$current"'/' Dockerfile
