#!/bin/sh

# Some other projects (autoconf & shunit2) say `` is more portable than $().
# shellcheck disable=2006

major_version() {
  printf %s\\n "$1" | sed 's/\..*//'
}

BASE=ubi`major_version "${UBI_VERSION?}"`-micro
docker build -t "gpgpdump:${VERSION?}-$BASE$UBI_VERSION" --build-arg ALPINE_VERSION --build-arg VERSION --build-arg BASE_IMAGE="redhat/${BASE}:$UBI_VERSION" - <Dockerfile-gpgpdump
