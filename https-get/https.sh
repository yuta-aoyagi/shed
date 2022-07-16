#!/bin/sh

# @(#)https.sh: a very tiny HTTPS client

# usage: ./https.sh "${host}" "${method} ${request_uri}" ${optional_rest_args}
# optional_rest_args are passed to the underlying `openssl s_client` command.
# HTTP response goes to stdout; s_client's messages goes to stderr.

# This script is developed for a pretty old Linux environment. Here are failed
# tries:
# - the certificate store is so old that it lacks ISRG Root X1
# - openssl extension in Ruby 1.8.7p352 supports TLS 1.2 but not SNI
# - curl 7.19.7 doesn't support TLS 1.2
# - Wget 1.12 doesn't support SNI
#
# cf. https://twitter.com/yuuta_aoyagi/status/1538493143720787968

# Limitation: when the HTTP response isn't completely received until `sleep 5`
# finishes, the script's behavior is undefined.

set -e

hos=${1:?missing host}
msg=${2:?missing message}

set -u

shift 2
{ printf '%s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$msg" "$hos" && sleep 5; } | \
  openssl s_client -connect "$hos:443" -servername "$hos" -quiet "$@"
