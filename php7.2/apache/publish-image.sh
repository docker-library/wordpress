#!/bin/sh

image="polyverse/polyscripted-wordpress"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker build -t $image:$headsha .
docker tag $image:$headsha $image:latest

if [[ "$1" == "-p" ]]; then
	docker push $image:$headsha
	docker push $image:latest
fi
