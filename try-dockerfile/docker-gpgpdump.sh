#!/bin/sh
docker build -t gpgpdump:0.14.0 --build-arg ALPINE_VERSION=3.16.1 --build-arg VERSION=0.14.0 --build-arg UBI_VERSION=8.6-394 - <Dockerfile-gpgpdump
