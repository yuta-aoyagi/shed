#!/bin/sh

set -u

MY_DIR=win10

find_token() {
  # shellcheck disable=SC2006
  fresh=`find "$token" -mmin -1`
}

msg() {
  printf '%s\n' "$1" >&2
  false
}

consume() {
  token=$MY_DIR/$1
  if find_token; then
    if [ "$fresh" ]; then
      rm "$token" || msg "shouldn't reach here"
    else
      msg "you don't have one-time token"
    fi
  else
    msg "shouldn't reach here"
  fi
}

do_work() {
  case $SSH_ORIGINAL_COMMAND in
    get) consume get && cat /dev/clipboard ;;
    put) consume put && cat >/dev/clipboard ;;
    *) msg "unknown command: $SSH_ORIGINAL_COMMAND"
  esac
}

ts_rb() {
  ruby --disable gems /etc/opt/openssh/ts.rb
}

# shellcheck disable=SC2006
log_file=$MY_DIR/`date -u +%Y-%m-%d`.log
{ do_work 2>&1 >&5 5>&- | ts_rb 5>&- | tee -a "$log_file" >&2; } 5>&1
