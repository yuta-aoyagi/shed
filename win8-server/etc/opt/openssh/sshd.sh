#!/bin/sh

set -eu

delayed_sshd() {
  sleep 15 && /usr/sbin/sshd -Def sshd_config
}

ts_rb() {
  ruby --disable gems ts.rb
}

cd /etc/opt/openssh
{ delayed_sshd 2>&1 >&5 5>&- | ts_rb >&2 2>&5; } 5>&1
