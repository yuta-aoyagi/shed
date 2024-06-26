# shellcheck shell=sh
# Beginning the first line by `#!` causes unspecified results; said in
# 2.1 Shell Introduction section of XCU volume of POSIX.1-2017

# Some other projects (GNU autoconf & shUnit2) say `...` is more portable
# than $(...)
# shellcheck disable=SC2006

# @(#)myqemu.sh: run the specified command with my QEMU environment

# Format the given arguments and print the result for user.
# The shell variable `prog` must be set a safe value.
msg() {
  {
    printf '%s: ' "$prog"
    # This function intentionally works like `printf` itself.
    # shellcheck disable=SC2059
    printf "$@"
    echo
  } >&2
}

err() {
  status=$1
  shift
  msg "$@"
  return "$status"
}

reject_unexpected_kind_of_characters() {
  case $1 in
    *[!./0-9A-Z_a-z-]*|//[!/]*)
      err 1 'rejected %s=[%s]' "$2" "$1" || return;;
  esac
  :
}

set_status() {
  return "$1"
}

accept_only_simple_path() {
  len=`printf %s "$1" | wc -c`
  if [ "$len" -gt 99 ]; then
    err 1 'rejected too long %s' "$2"
  else
    reject_unexpected_kind_of_characters "$@"
  fi
}

# Transform the given pathname $1 into the aunt mingw.sh (a sister of parent
# directory). Return $1 itself, when the parent directory has unexpected
# structure.
# $1: where to search from
mingw_sh_near() {
  printf %s\\n "$1" | sed 's@myqemu/myqemu\.sh$@mingw.sh@'
}

EX_USAGE=64

find_mingw_sh() {
  mingw_sh=`mingw_sh_near "$prog"`
  if [ "x$mingw_sh" != "x$prog" ] && [ -r "$mingw_sh" ]; then
    : # OK
  else
    err $EX_USAGE \
      "cannot find mingw.sh because prog(\$0)=[%s] is unexpected" "$prog"
  fi
}

EX_DATAERR=65

decide_qemu_base() {
  ( set +u && [ ${QEMU_BASE+x} ] ) ||
    QEMU_BASE=~/work/build-qemu-6.0.1/qemu-6.0.1
  accept_only_simple_path "$QEMU_BASE" QEMU_BASE || return $EX_DATAERR

  if [ -x "$QEMU_BASE/build/qemu-img" ] &&
       [ -x "$QEMU_BASE/build/qemu-system-x86_64" ]; then
    : # OK
  else
    err $EX_DATAERR \
      "rejected QEMU_BASE lacking any of build/qemu-{img,system-*}"
  fi
}

find_l_arg() {
  l_arg=`cygpath -m "$QEMU_BASE/pc-bios"`
  case $l_arg in
    *[!./0-9:A-Z_a-z-]*)
      err $EX_DATAERR "rejected l_arg [%s]" "$l_arg";;
    *) : ;;
  esac
}

# $1: set to $0 or to an overrided value when testing
# $2: shell command to be run
do_work() {
  set -eu

  prog=myqemu.sh # a dummy value to be replaced below
  accept_only_simple_path "$1" "prog(\$0)" || return $EX_USAGE
  prog=$1 # $1 is now safe for $prog & msg()

  find_mingw_sh && decide_qemu_base || return

  find_l_arg || return

  wrapped_qemu="sh $mingw_sh $QEMU_BASE/build/qemu-"
  QEMU_IMG="${wrapped_qemu}img" QEMU="${wrapped_qemu}system-x86_64" \
    QEMUFLAGS="-L $l_arg" sh -c "$2"
}

[ ${dont_run_actually+y} ] || do_work "$0" "$@"
