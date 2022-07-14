#!/usr/bin/env bash
set -Eeuo pipefail

[ -f versions.json ] # run "versions.sh" first

jqt='.jq-template.awk'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
	jqt="$BASHBREW_SCRIPTS/jq-template.awk"
elif [ "$BASH_SOURCE" -nt "$jqt" ]; then
	# https://github.com/docker-library/bashbrew/blob/master/scripts/jq-template.awk
	wget -qO "$jqt" 'https://github.com/docker-library/bashbrew/raw/9f6a35772ac863a0241f147c820354e4008edf38/scripts/jq-template.awk'
fi

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

for version; do
	export version

	rm -rf "$version/"

	phpVersions="$(jq -r '.[env.version].phpVersions | map(@sh) | join(" ")' versions.json)"
	eval "phpVersions=( $phpVersions )"
	variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

	for phpVersion in "${phpVersions[@]}"; do
		export phpVersion

		for variant in "${variants[@]}"; do
			export variant

			dir="$version/php$phpVersion/$variant"
			mkdir -p "$dir"

			echo "processing $dir ..."

			{
				generated_warning
				gawk -f "$jqt" Dockerfile.template
			} > "$dir/Dockerfile"

			if [ "$version" = 'cli' ]; then
				cp -a cli-entrypoint.sh "$dir/docker-entrypoint.sh"
			else
				cp -a docker-entrypoint.sh wp-config-docker.php "$dir/"
			fi
		done
	done
done
