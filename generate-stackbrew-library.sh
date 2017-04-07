#!/bin/bash
set -eu

defaultPhpVersion='php5.6'
defaultVariant='apache'

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

phpVersions=( php*.*/ )
phpVersions=( "${phpVersions[@]%/}" )

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

for phpVersion in "${phpVersions[@]}"; do
	for variant in apache fpm fpm-alpine; do
		dir="$phpVersion/$variant"
		[ -f "$dir/Dockerfile" ] || continue

		commit="$(dirCommit "$dir")"

		fullVersion="$(git show "$commit":"$dir/Dockerfile" | awk '$1 == "ENV" && $2 == "WORDPRESS_VERSION" { print $3; exit }')"
		if [[ "$fullVersion" != *.*.* && "$fullVersion" == *.* ]]; then
			fullVersion+='.0'
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

		phpVersionAliases=( "${versionAliases[@]/%/-$phpVersion}" )
		phpVersionAliases=( "${phpVersionAliases[@]//latest-/}" )

		variantAliases=( "${versionAliases[@]/%/-$variant}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		phpVersionVariantAliases=( "${versionAliases[@]/%/-$phpVersion-$variant}" )
		phpVersionVariantAliases=( "${phpVersionVariantAliases[@]//latest-/}" )

		fullAliases=()

		if [ "$phpVersion" = "$defaultPhpVersion" ]; then
			fullAliases+=( "${variantAliases[@]}" )

			if [ "$variant" = "$defaultVariant" ]; then
				fullAliases+=( "${versionAliases[@]}" )
			fi
		fi

		fullAliases+=(
			"${phpVersionVariantAliases[@]}"
		)

		if [ "$variant" = "$defaultVariant" ]; then
			fullAliases+=( "${phpVersionAliases[@]}" )
		fi

		echo
		cat <<-EOE
			Tags: $(join ', ' "${fullAliases[@]}")
			GitCommit: $commit
			Directory: $dir
		EOE
	done
done

echo
echo '# Now, wp-cli variants (which do _not_ include WordPress, so no WordPress version number -- only wp-cli version)'

for phpVersion in "${phpVersions[@]}"; do
	variant='cli'

	dir="$phpVersion/$variant"
	[ -f "$dir/Dockerfile" ] || continue

	commit="$(dirCommit "$dir")"

	fullVersion="$(git show "$commit":"$dir/Dockerfile" | awk '$1 == "ENV" && $2 == "WORDPRESS_CLI_VERSION" { print $3; exit }')"

	versionAliases=()
	while [ "${fullVersion%[.-]*}" != "$fullVersion" ]; do
		versionAliases+=( $fullVersion )
		fullVersion="${fullVersion%[.-]*}"
	done
	versionAliases+=(
		$fullVersion
		latest
	)

	phpVersionAliases=( "${versionAliases[@]/#/$phpVersion-}" )
	phpVersionAliases=( "${phpVersionAliases[@]//-latest/}" )

	variantAliases=( "${versionAliases[@]/#/$variant-}" )
	variantAliases=( "${variantAliases[@]//-latest/}" )

	phpVersionVariantAliases=( "${versionAliases[@]/#/$variant-}" )
	phpVersionVariantAliases=( "${phpVersionVariantAliases[@]//-latest/}" )
	phpVersionVariantAliases=( "${phpVersionVariantAliases[@]/%/-$phpVersion}" )

	fullAliases=()

	if [ "$phpVersion" = "$defaultPhpVersion" ]; then
		fullAliases+=( "${variantAliases[@]}" )
	fi

	fullAliases+=(
		"${phpVersionVariantAliases[@]}"
	)

	echo
	cat <<-EOE
		Tags: $(join ', ' "${fullAliases[@]}")
		GitCommit: $commit
		Directory: $dir
	EOE
done
