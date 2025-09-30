#!/usr/bin/env bash

# https://github.com/docker-library/official-images/blob/7629e0d0a836d0ec718a6e053753479227cf6825/test/config.sh

imageTests[wordpress:apache]+='
	wordpress-ensure-installed
'
imageTests[wordpress:fpm]+='
	wordpress-ensure-installed
'
