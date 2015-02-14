#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

url='git://github.com/docker-library/wordpress'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

defaultVariant='apache'

for variant in apache fpm; do
	commit="$(git log -1 --format='format:%H' -- "$variant")"
	fullVersion="$(grep -m1 'ENV WORDPRESS_VERSION ' "$variant/Dockerfile" | cut -d' ' -f3)"

	versionAliases=()
	while [ "${fullVersion%.*}" != "$fullVersion" ]; do
		versionAliases+=( $fullVersion-$variant )
		if [ "$variant" = "$defaultVariant" ]; then
			versionAliases+=( $fullVersion )
		fi
		fullVersion="${fullVersion%.*}"
	done
	versionAliases+=( $fullVersion-$variant $variant )
	if [ "$variant" = "$defaultVariant" ]; then
		versionAliases+=( $fullVersion latest )
	fi

	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $variant"
	done
done
