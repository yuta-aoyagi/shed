#!/bin/sh

set -e

hos=${1:?missing host}
msg=${2:?missing message}

set -u

shift 2
{ printf '%s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "$msg" "$hos" && sleep 5; } | \
  openssl s_client -connect "$hos:443" -servername "$hos" -quiet "$@"
