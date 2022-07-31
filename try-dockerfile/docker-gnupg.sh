#!/bin/sh
docker build -t gnupg:2.2.35-alpine3.16.1 --build-arg ALPINE_VERSION=3.16.1 - <Dockerfile-gnupg
