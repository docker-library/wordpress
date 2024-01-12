#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ "${#versions[@]}" -eq 0 ]; then
	versions=( */ )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )

unit="$(
	bashbrew list https://github.com/docker-library/official-images/raw/HEAD/library/unit \
		| jq -nR '
			[
				# filter tags down to just "N[.N[.N]]-phpN.N" (capturing "version" and "php version")
				inputs
				| capture(":(?<version>[0-9]+([.][0-9]+)*)-php(?<php>[0-9]+[.][0-9]+)$")
				| .split = (.version | split(".") | map(tonumber? // .)) # pre-parse version numbers (for filtering and sorting)
				| select(.split[0] == 1) # filter down to just 1.x versions (attempt to avoid major breakage)
			]
			# sort the list in descending version sort order
			| unique_by([ .split, .php ])
			| reverse
			| (
				# find the highest and least specific version number (2 preferred over 1 over 2.3 over 2.3.4)
				map(.version)
				| unique_by(indices(".") | length)
				| .[0] // error("no suitable unit version found")
			) as $version
			| {
				version: $version,
				phpVersions: map(
					select(.version == $version)
					| .php
				),
			}
		'
)"

for version in "${versions[@]}"; do
	export version

	doc='{}'

	fullVersion=
	if [ "$version" = 'cli' ]; then
		possibleVersions=( $(
			git ls-remote --tags 'https://github.com/wp-cli/wp-cli.git' \
				| sed -r 's!^[^\t]+\trefs/tags/v([^^]+).*$!\1!g' \
				| sort --version-sort --reverse
		) )
		for possibleVersion in "${possibleVersions[@]}"; do
			url="https://github.com/wp-cli/wp-cli/releases/download/v${possibleVersion}/wp-cli-${possibleVersion}.phar.sha512"
			if sha512="$(wget -qO- "$url" 2>/dev/null)" && [ -n "$sha512" ]; then
				export sha512
				doc="$(jq <<<"$doc" -c '.sha512 = env.sha512')"
				fullVersion="$possibleVersion"
				break
			fi
		done
	else
		possibleVersion="$(
			wget -qO- "https://api.wordpress.org/core/version-check/1.7/?channel=$version" \
				| jq -r '.offers[0].current'
		)"
		if [ -n "$possibleVersion" ] && sha1="$(wget -qO- "https://wordpress.org/wordpress-$possibleVersion.tar.gz.sha1")" && [ -n "$sha1" ]; then
			fullVersion="$possibleVersion"
			export sha1 fullVersion
			doc="$(jq <<<"$doc" -c '.sha1 = env.sha1 | .upstream = env.fullVersion')"
			if [[ "$fullVersion" != *.*.* && "$fullVersion" == *.* && "$fullVersion" != *-* ]]; then
				fullVersion+='.0'
			fi
		fi
	fi
	if [ -z "$fullVersion" ]; then
		echo >&2 "error: failed to find version for $version"
		exit 1
	fi
	echo "$version: $fullVersion"

	export fullVersion
	json="$(
		jq <<<"$json" -c --argjson doc "$doc" --argjson unit "$unit" '
			.[env.version] = {
				version: env.fullVersion,
				phpVersions: [ "8.1", "8.2", "8.3" ],
				variants: (
					if env.version == "cli" then
						[ "alpine" ]
					else
						[ "apache", "fpm", "fpm-alpine", "unit" ]
					end
				),
			} + if env.version == "cli" then {} else {
				unit: $unit,
			} end + $doc
		'
	)"
done

jq <<<"$json" -S . > versions.json
