#!/bin/bash
set -e

current="$(curl -sSL 'http://api.wordpress.org/core/version-check/1.7/' | sed -r 's/^.*"current":"([^"]+)".*$/\1/')"

upstream="$current"
if [[ "$current" != *.*.* ]]; then
	# turn "4.0" into "4.0.0"
	current+='.0'
fi

set -x
sed -ri '
	s/^(ENV WORDPRESS_VERSION) .*/\1 '"$current"'/;
	s/^(ENV WORDPRESS_UPSTREAM_VERSION) .*/\1 '"$upstream"'/;
' Dockerfile
