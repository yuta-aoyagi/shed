#!/bin/sh

set -u

(
  PATH=${PATH##*bin:}:/usr/x86_64-w64-mingw32/sys-root/mingw/bin
  "$@"
)
r=$?
printf "subprocess \`%s' exited with $r\\n" "$1" >&2
exit "$r"
