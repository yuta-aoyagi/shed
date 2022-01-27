#!/bin/sh

PATH=${PATH##*bin:}:/usr/x86_64-w64-mingw32/sys-root/mingw/bin
"$@"
