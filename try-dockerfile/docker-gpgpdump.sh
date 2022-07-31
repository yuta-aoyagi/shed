#!/bin/sh
docker build -t "gpgpdump:${VERSION?}-ubi8-micro${UBI_VERSION?}" --build-arg ALPINE_VERSION --build-arg VERSION --build-arg UBI_VERSION - <Dockerfile-gpgpdump
