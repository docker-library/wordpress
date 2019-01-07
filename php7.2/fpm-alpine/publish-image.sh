#!/bin/sh

image="polyverse/polyscripted-wordpress"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker build -t $image:alpine-$headsha .
docker tag $image:alpine-$headsha $image:alpine-latest
docker tag $image:alpine-$headsha $image:latest

if [[ "$1" == "-p" ]]; then
	docker push $image:alpine-$headsha
	docker push $image:alpine-latest
	docker push $image:latest
fi
