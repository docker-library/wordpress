#!/usr/bin/env bash
set -Eeuo pipefail

# https://wordpress.org/about/requirements/
# https://wordpress.org/support/update-php/#before-you-update-your-php-version
defaultPhpVersion='php7.4'
defaultVariant='apache'

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

# make sure "latest" is first and "beta" is last
IFS=$'\n'; set -- $(tac <<<"$*"); unset IFS

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

getArches() {
	local repo="$1"; shift
	local officialImagesUrl='https://github.com/docker-library/official-images/raw/master/library/'

	eval "declare -g -A parentRepoToArches=( $(
		find -name 'Dockerfile' -exec awk '
				toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
					print "'"$officialImagesUrl"'" $2
				}
			' '{}' + \
			| sort -u \
			| xargs bashbrew cat --format '[{{ .RepoName }}:{{ .TagName }}]="{{ join " " .TagEntry.Architectures }}"'
	) )"
}
getArches 'wordpress'

cat <<-EOH
# this file is generated via https://github.com/docker-library/wordpress/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/wordpress.git
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for version; do
	export version

	phpVersions="$(jq -r '.[env.version].phpVersions | map(@sh) | join(" ")' versions.json)"
	eval "phpVersions=( $phpVersions )"
	variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

	fullVersion="$(jq -r '.[env.version].version' versions.json)"

	if [ "$version" = 'beta' ] && latestVersion="$(jq -r '.latest.version // ""' versions.json)" && [ "$latestVersion" = "$fullVersion" ]; then
		# "beta" channel even with release, skip it
		: #continue # TODO once something newer than 5.6 is released, this should be restored (explicit "beta" for allowing pre-release testing of "wp-config-docker.php")
	fi

	versionAliases=()
	while [ "${fullVersion%[.-]*}" != "$fullVersion" ]; do
		versionAliases+=( $fullVersion )
		fullVersion="${fullVersion%[.-]*}"
	done
	versionAliases+=(
		$fullVersion
		latest
	)

	for phpVersion in "${phpVersions[@]}"; do
		phpVersion="php$phpVersion"
		for variant in "${variants[@]}"; do
			dir="$version/$phpVersion/$variant"
			[ -f "$dir/Dockerfile" ] || continue

			commit="$(dirCommit "$dir")"

			phpVersionAliases=( "${versionAliases[@]/%/-$phpVersion}" )
			phpVersionAliases=( "${phpVersionAliases[@]//latest-/}" )

			if [ "$version" != 'cli' ]; then
				variantAliases=( "${versionAliases[@]/%/-$variant}" )
				variantAliases=( "${variantAliases[@]//latest-/}" )

				phpVersionVariantAliases=( "${versionAliases[@]/%/-$phpVersion-$variant}" )
				phpVersionVariantAliases=( "${phpVersionVariantAliases[@]//latest-/}" )
			fi

			fullAliases=()
			if [ "$version" != 'cli' ]; then
				if [ "$phpVersion" = "$defaultPhpVersion" ]; then
					fullAliases+=( "${variantAliases[@]}" )
					if [ "$variant" = "$defaultVariant" ]; then
						fullAliases+=( "${versionAliases[@]}" )
					fi
				fi
				fullAliases+=( "${phpVersionVariantAliases[@]}" )
				if [ "$variant" = "$defaultVariant" ]; then
					fullAliases+=( "${phpVersionAliases[@]}" )
				fi
			else
				if [ "$phpVersion" = "$defaultPhpVersion" ]; then
					fullAliases+=( "${versionAliases[@]}" )
				fi
				fullAliases+=( "${phpVersionAliases[@]}" )
			fi

			if [ "$version" != 'latest' ]; then
				fullAliases=( "${fullAliases[@]/#/$version-}" )
				fullAliases=( "${fullAliases[@]//-latest/}" )
			fi

			variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$dir/Dockerfile")"
			variantArches="${parentRepoToArches[$variantParent]}"

			echo
			cat <<-EOE
				Tags: $(join ', ' "${fullAliases[@]}")
				Architectures: $(join ', ' $variantArches)
				GitCommit: $commit
				Directory: $dir
			EOE
		done
	done
done
