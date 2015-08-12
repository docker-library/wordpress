#!/bin/bash
set -eo pipefail

current="$(curl -sSL 'http://api.wordpress.org/core/version-check/1.7/' | sed -r 's/^.*"current":"([^"]+)".*$/\1/')"

sha1="$(curl -sSL "https://wordpress.org/wordpress-$current.tar.gz.sha1")"

travisEnv=
for variant in apache fpm; do
	(
		set -x

		sed -ri '
			s/^(ENV WORDPRESS_VERSION) .*/\1 '"$current"'/;
			s/^(ENV WORDPRESS_SHA1) .*/\1 '"$sha1"'/;
		' "$variant/Dockerfile"

		cp docker-entrypoint.sh "$variant/docker-entrypoint.sh"
	)
	
	travisEnv+='\n  - VARIANT='"$variant"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
