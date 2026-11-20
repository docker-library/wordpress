#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ "${#versions[@]}" -eq 0 ]; then
	# this is also the order of "versions.json" (which "generate-stackbrew-library.sh" preserves)
	versions=( latest beta cli )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )

# https://make.wordpress.org/core/handbook/references/php-compatibility-and-wordpress-versions/ (via the REST API, so we get the same HTML table that page renders)
# becomes { "7.1": [ "8.5", "8.4", ... ], ... } (which PHP versions are documented as "Y" for each WordPress "X.Y")
phpCompat="$(
	wget -qO- 'https://make.wordpress.org/core/wp-json/wp/v2/handbook?slug=php-compatibility-and-wordpress-versions' | jq -c '
		# the first table is the compatibility matrix (WordPress versions down the side, PHP versions across the top, "Y" or "N" in each cell)
		.[0].content.rendered
		| [ match("<table.*?</table>"; "gs").string ][0]
		| [
			match("<tr.*?</tr>"; "gs").string
			# the text of each cell in this row
			| [
				match("<t[hd][^>]*>(.*?)</t[hd]>"; "gs").captures[0].string
				| gsub("<[^>]+>"; "")
				| gsub("\\s+"; " ")
				| gsub("^ | $"; "")
			]
		]
		| .[0] as $header
		| if $header[0] != "WP / PHP Version" then
			error("unexpected PHP compatibility table header: \($header)")
		else . end
		| .[1:]
		| map(
			def is_xy:
				test("^[0-9]+[.][0-9]+$")
			;

			. as $row
			| {
				key: $row[0],
				value: [
					range(1; $row | length)
					| select($row[.] == "Y")
					| $header[.]
					| select(is_xy)
				],
			}
			| select(.key | is_xy)
		)
		| from_entries
		| if length == 0 then
			error("failed to parse PHP compatibility table")
		else . end
	'
)"

# the variants we build for each version (and so the variants the upstream "php" image needs to have for us to build that PHP version)
phpVariants='{
	"latest": [ "apache", "fpm", "fpm-alpine" ],
	"beta": [ "apache", "fpm", "fpm-alpine" ],
	"cli": [ "alpine" ]
}'

# the upstream "php" images, pre-parsed (and pre-filtered) into { "8.6": { "apache": { from, suite, arches }, ... }, ... } (newest first, with pre-releases last)
phpImages="$(
	bashbrew cat --format '
		{{- range .Entries -}}
			{
				"tags": {{ $.Tags "" false . | json }},
				"arches": {{ .Architectures | json }},
				"constraints": {{ .Constraints | json }}
			}
			{{- "\n" -}}
		{{- end -}}
	' "${BASHBREW_LIBRARY:-https://github.com/docker-library/official-images/raw/HEAD/library}/php" \
		| jq --slurp -c --argjson phpVariants "$phpVariants" '
			# "8.6" -> [ 8, 6 ], "8.6-rc" -> [ 8, 6 ]
			def php_ver:
				split("-")[0] | split(".") | map(tonumber)
			;

			[
				.[]
				# each entry is one upstream image, and we parse all of its tags: "php:X.Y-REST" becomes { version: "X.Y", rest: "REST" }
				# (this skips "X.Y.Z" tags, so we only see the floating "X.Y" ones, including "X.Y-rc" for pre-releases)
				| [ .tags[] | capture("^php:(?<version>[0-9]+[.][0-9]+(-rc)?)(-(?<rest>.+))?$") ] as $tags
				# the "bare" tags for our variants ("apache", "fpm-alpine", "alpine")
				| ($tags[] | select(IN(.rest; $phpVariants[][]))) as $bare
				# the same entry has a more specific tag for this variant that includes the suite ("apache" -> "apache-trixie", "fpm-alpine" -> "fpm-alpine3.24", "alpine" -> "alpine3.24")
				| (
					[
						$tags[]
						| select(
							.version == $bare.version
							and ((.rest // "") | startswith($bare.rest) and . != $bare.rest)
							# (alpine tags have the version glued on without a dash, so we cannot just look for a "-" suffix)
						)
					]
					# we need exactly one to pin our "FROM" to (none just means this entry is not usable)
					| if length > 1 then
						error("multiple suite tags for php:\($bare.version)-\($bare.rest): \(.)")
					else .[] end # (this is also our filter: an empty array emits nothing)
				) as $qualified
				| {
					version: $bare.version,
					variant: $bare.rest,
					from: "php:\($bare.version)-\($qualified.rest)",
					suite: ($qualified.rest | split("-")[-1]), # (the suite is always the last component)
					arches,
					constraints,
				}
			]

			# pre-releases for a version that is already GA upstream are just noise (we only want "8.7-rc" if there is no "8.7" yet)
			| ([ .[].version | select(endswith("-rc") | not) ] | unique) as $ga
			| map(select(.version | (endswith("-rc") | not) or (IN(rtrimstr("-rc"); $ga[]) | not)))

			| group_by(.version)
			| map(
				if (map(.variant) | length) != (map(.variant) | unique | length) then
					error("multiple matches for php:\(.[0].version)")
				else . end
				| {
					key: .[0].version,
					value: (
						map({
							key: .variant,
							value: (
								del(.version, .variant)
								| if .constraints == [] then del(.constraints) else . end
							),
						})
						| from_entries
					),
				}
			)

			# newest first, with pre-releases (like "8.6-rc") always last
			| sort_by([
				(.key | endswith("-rc")),
				(.key | php_ver | map(-.))
			])
			| from_entries
		'
)"

for version in "${versions[@]}"; do
	export version

	doc='{}'

	# the minimum PHP version supported by this release of WordPress (empty means no explicit lower bound)
	phpMin=
	export phpMin

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
		check="$(wget -qO- "https://api.wordpress.org/core/version-check/1.7/?channel=$version")"
		possibleVersion="$(jq <<<"$check" -r '.offers[0].current')"
		phpMin="$(jq <<<"$check" -r '.offers[0].php_version')"
		if [ -n "$possibleVersion" ] && sha1="$(wget -qO- "https://wordpress.org/wordpress-$possibleVersion.tar.gz.sha1")" && [ -n "$sha1" ]; then
			fullVersion="$possibleVersion"
			export sha1
			doc="$(jq <<<"$doc" -c '.sha1 = env.sha1')"
		fi
	fi
	if [ -z "$fullVersion" ]; then
		echo >&2 "error: failed to find version for $version"
		exit 1
	fi
	echo "$version: $fullVersion"

	export fullVersion
	json="$(
		jq <<<"$json" -c --argjson doc "$doc" --argjson phpCompat "$phpCompat" --argjson phpVariants "$phpVariants" --argjson phpImages "$phpImages" '
			# "8.6" -> [ 8, 6 ], "8.6-rc" -> [ 8, 6 ]
			def php_ver:
				split("-")[0] | split(".") | map(tonumber)
			;

			($phpVariants[env.version] // error("unknown variants for \(env.version)")) as $variants

			# explicit lower bound for PHP versions ("cli" has no such thing, so it is unbounded)
			| (
				if env.version == "cli" then null else
					env.phpMin | select(. != "") // error("missing minimum PHP version for \(env.version)") | php_ver
				end
			) as $phpMin

			# the PHP versions (and the exact "FROM" for each variant) we can build, in the order of "$phpImages"
			| (
				$phpImages
				| to_entries

				# TODO consider including PHP versions that only have some of our variants (instead of skipping them entirely)?
				| map(select(.value as $images | all($variants[]; in($images))))

				| map(select($phpMin == null or (.key | php_ver) >= $phpMin))

				# { "8.6": { variants: { ... } }, ... }
				| map({
					key,
					value: {
						variants: (
							.value as $images
							| $variants
							| map({ key: ., value: $images[.] })
							| from_entries
						),
					},
				})
				| from_entries
			) as $php

			| ($php | keys_unsorted | map(select(endswith("-rc") | not))) as $gaVersions

			# the newest WordPress "X.Y" we have PHP compatibility data for ("cli" is not WordPress, and unreleased WordPress versions have no row yet, so both use the newest row available)
			| (
				if env.version == "cli" then null else
					env.fullVersion | php_ver | .[:2]
				end
			) as $wpVersion

			| .[env.version] = (
				{ version: env.fullVersion }
				+ $doc
				+ {
					# the newest PHP version documented as supported ("Y") for this WordPress release (and that we have an image for)
					# background and rationale: https://github.com/docker-library/wordpress/issues/959
					phpDefault: (
						$phpCompat
						| to_entries
						| map(select($wpVersion == null or (.key | php_ver) <= $wpVersion))
						| (max_by(.key | php_ver) // error("no PHP compatibility data for \(env.version)"))
						| .value
						| map(select(IN($gaVersions[])))
						| (max_by(php_ver) // error("no supported PHP versions available for \(env.version)"))
					),

					php: $php,
				}
			)
		'
	)"
done

jq <<<"$json" '.' > versions.json
