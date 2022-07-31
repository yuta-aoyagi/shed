#!/bin/sh
docker build -t "gnupg:${VERSION_IN_TAG?}-alpine${ALPINE_VERSION?}" --build-arg ALPINE_VERSION - <Dockerfile-gnupg
