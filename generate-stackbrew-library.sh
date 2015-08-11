#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

url='git://github.com/docker-library/wordpress'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

defaultVariant='apache'

for variant in apache fpm; do
	commit="$(cd "$variant" && git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
	fullVersion="$(grep -m1 'ENV WORDPRESS_VERSION ' "$variant/Dockerfile" | cut -d' ' -f3)"
	if [[ "$fullVersion" != *.*.* && "$fullVersion" == *.* ]]; then
		fullVersion+='.0'
	fi

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
