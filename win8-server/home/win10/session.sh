#!/bin/sh

set -u

MY_DIR=win10

msg() {
  printf '%s\n' "$1" >&2
}

find_token() {
  # shellcheck disable=SC2006
  fresh=`find "$MY_DIR" -path "$token" -mmin -1`
}

on_error() {
  msg "$1"
  false
}

consume() {
  token=$MY_DIR/$1
  if find_token; then
    if [ "$fresh" ]; then
      rm "$token" || on_error "shouldn't reach here"
    else
      on_error "you don't have one-time token"
    fi
  else
    on_error "shouldn't reach here"
  fi
}

do_get() {
  cat /dev/clipboard
}

do_put() {
  cat >/dev/clipboard
}

process() {
  consume "$1" && $2
}

dispatch() {
  case $1 in
    get) process get do_get ;;
    put) process put do_put ;;
    *) on_error "unknown command: $1"
  esac
}

do_work() {
  dispatch "$SSH_ORIGINAL_COMMAND"
}

ts_rb() {
  ruby --disable gems /etc/opt/openssh/ts.rb
}

# shellcheck disable=SC2006
log_file=$MY_DIR/`date -u +%Y-%m-%d`.log
{ do_work 2>&1 >&5 5>&- | ts_rb 5>&- | tee -a "$log_file" >&2; } 5>&1
