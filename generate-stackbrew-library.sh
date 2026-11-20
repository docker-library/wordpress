#!/usr/bin/env bash
set -Eeuo pipefail

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# get the most recent commit which modified any files related to a build context
commit="$(git log -1 --format='format:%H' HEAD -- '[^.]*/**')"
[ -n "$commit" ]

# (this script or the "jq" file it runs)
selfCommit="$(git log -1 --format='format:%H' HEAD -- 'generate-stackbrew-library.*')"

cat <<-EOH
# this file is generated via https://github.com/docker-library/wordpress/blob/$selfCommit/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/wordpress.git
GitCommit: $commit
EOH

exec jq \
	--raw-output \
	--from-file generate-stackbrew-library.jq \
	versions.json \
	--args -- "$@"
