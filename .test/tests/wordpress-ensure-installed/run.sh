#!/usr/bin/env bash
set -Eeuo pipefail

docker run --rm "$1" sh -euc '
	[ ! -s wp-includes/version.php ] || exit 1
	docker-ensure-installed.sh
	[ -s wp-includes/version.php ] || exit 1
'
