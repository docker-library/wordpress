#!/bin/bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

phpVersions=( "$@" )
if [ ${#phpVersions[@]} -eq 0 ]; then
	phpVersions=( php*.*/ )
fi
phpVersions=( "${phpVersions[@]%/}" )

current="$(curl -fsSL 'http://api.wordpress.org/core/version-check/1.7/' | jq -r '.offers[0].current')"
sha1="$(curl -fsSL "https://wordpress.org/wordpress-$current.tar.gz.sha1")"

declare -A variantExtras=(
	[apache]='\nRUN a2enmod rewrite expires\n'
	[fpm]=''
)
declare -A variantCmds=(
	[apache]='apache2-foreground'
	[fpm]='php-fpm'
)

travisEnv=
for phpVersion in "${phpVersions[@]}"; do
	phpVersionDir="$phpVersion"
	phpVersion="${phpVersion#php}"

	for variant in apache fpm; do
		dir="$phpVersionDir/$variant"
		mkdir -p "$dir"

		extras="${variantExtras[$variant]}"
		cmd="${variantCmds[$variant]}"

		(
			set -x

			sed -r \
				-e 's!%%WORDPRESS_VERSION%%!'"$current"'!g' \
				-e 's!%%WORDPRESS_SHA1%%!'"$sha1"'!g' \
				-e 's!%%PHP_VERSION%%!'"$phpVersion"'!g' \
				-e 's!%%VARIANT%%!'"$variant"'!g' \
				-e 's!%%VARIANT_EXTRAS%%!'"$extras"'!g' \
				-e 's!%%CMD%%!'"$cmd"'!g' \
				Dockerfile.template > "$dir/Dockerfile"

			cp docker-entrypoint.sh "$dir/docker-entrypoint.sh"
		)

		travisEnv+='\n  - VARIANT='"$dir"
	done
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
