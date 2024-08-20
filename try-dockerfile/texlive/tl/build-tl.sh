# shellcheck shell=sh
# Beginning the first line by `#!` causes unspecified results; said in
# 2.1 Shell Introduction section of XCU volume of POSIX.1-2017

: "${ALPINE_VERSION=3.20.2@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5}"
docker build "$@" --build-arg ALPINE_VERSION="$ALPINE_VERSION" .
