#!/usr/bin/env bash
set -Eeuo pipefail

# Renders the upstream Dockerfile.template for one WordPress branch and one PHP
# version, resolving the latest WordPress patch release of that branch.
# Upstream files are never modified: the rendering happens in dow/build/.
#
#   dow/prepare.sh 6.8-php8.3
#
# Prints shell exports on stdout (meant for "$BASH_ENV"), logs on stderr.

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")/.."

combo="${1:?usage: $0 <wordpress branch>-php<php version>, e.g. 6.8-php8.3}"
wpBranch="${combo%-php*}"
phpVersion="${combo##*-php}"
variant='fpm-alpine'

if [[ ! "$wpBranch" =~ ^[0-9]+\.[0-9]+$ || ! "$phpVersion" =~ ^[0-9]+\.[0-9]+$ ]]; then
	echo >&2 "error: invalid '$combo', expected e.g. 6.8-php8.3"
	exit 1
fi

# every released version is a key of stable-check, "X.Y" being the X.Y.0 release
upstream="$(
	wget -qO- 'https://api.wordpress.org/core/stable-check/1.0/' \
		| jq -r --arg b "$wpBranch" 'keys[] | select(. == $b or startswith($b + "."))' \
		| sort -V \
		| tail -1
)"
if [ -z "$upstream" ]; then
	echo >&2 "error: no WordPress release found for branch $wpBranch"
	exit 1
fi
sha1="$(wget -qO- "https://wordpress.org/wordpress-$upstream.tar.gz.sha1")"
if [ -z "$sha1" ]; then
	echo >&2 "error: no sha1 found for WordPress $upstream"
	exit 1
fi

fullVersion="$upstream"
if [[ "$fullVersion" != *.*.* ]]; then
	fullVersion+='.0'
fi
echo >&2 "WordPress $wpBranch -> $fullVersion (sha1 $sha1), PHP $phpVersion, $variant"

work="dow/build/$combo"
rm -rf "$work"
mkdir -p "$work"
cp -a Dockerfile.template apply-templates.sh docker-entrypoint.sh wp-config-docker.php cli-entrypoint.sh "$work/"

export wpBranch phpVersion variant upstream sha1 fullVersion
jq -n -S '{
	(env.wpBranch): {
		version: env.fullVersion,
		upstream: env.upstream,
		sha1: env.sha1,
		phpVersions: [ env.phpVersion ],
		variants: [ env.variant ],
	}
}' > "$work/versions.json"

( cd "$work" && ./apply-templates.sh "$wpBranch" ) >&2

buildDir="$work/$wpBranch/php$phpVersion/$variant"
[ -f "$buildDir/Dockerfile" ]

echo "export WP_FULL_VERSION='$fullVersion'"
echo "export PHP_VERSION='$phpVersion'"
echo "export BUILD_DIR='$PWD/$buildDir'"
