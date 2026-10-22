# Local helpers around dow/prepare.sh, run from the repository root with
# "make -C dow <target>". The version list is the CircleCI build matrix.
#
#   make -C dow list
#   make -C dow build VERSION=6.8-php8.4
#   make -C dow test VERSION=6.8-php8.4
#   make -C dow build-all

SHELL := bash
.SHELLFLAGS := -Eeuo pipefail -c

CONFIG := ../.circleci/config.yml
VERSIONS := $(shell grep -oE '"[0-9]+\.[0-9]+-php[0-9]+\.[0-9]+"' $(CONFIG) | tr -d '"')
VERSION ?=
IMAGE := dow-wordpress

.PHONY: list prepare build test build-all validate clean check-version

list:
	@printf '%s\n' $(VERSIONS)

check-version:
	@[ -n "$(VERSION)" ] || { echo >&2 'usage: make -C dow $(MAKECMDGOALS) VERSION=6.8-php8.4'; exit 1; }

# render the Dockerfile in dow/build/ and print the resolved versions
prepare: check-version
	./prepare.sh $(VERSION)

build: check-version
	eval "$$(./prepare.sh $(VERSION))"; \
	docker build --pull -t $(IMAGE):$(VERSION)-fpm-alpine "$$BUILD_DIR"

test: check-version
	docker run --rm $(IMAGE):$(VERSION)-fpm-alpine sh -c \
		'php -r "echo \"PHP \", PHP_VERSION, PHP_EOL;"; grep "^\$$wp_version" /usr/src/wordpress/wp-includes/version.php'

build-all:
	for v in $(VERSIONS); do $(MAKE) --no-print-directory build test VERSION=$$v; done

validate:
	circleci config validate --org-id b96fa597-f66e-4703-b4da-3792c03c93b2 $(CONFIG)

clean:
	rm -rf build
