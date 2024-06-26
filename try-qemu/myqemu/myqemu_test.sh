# shellcheck shell=sh
# Beginning the first line by `#!` causes unspecified results; said in
# 2.1 Shell Introduction section of XCU volume of POSIX.1-2017

# Some other projects (GNU autoconf & shUnit2) say `...` is more portable
# than $(...)
# shellcheck disable=SC2006

TARGET=../myqemu/myqemu.sh # tricky relative path

test_runs_qemu_img() {
  do_work "$TARGET" "\$QEMU_IMG --version" 2>&1 | grep -q 'qemu-img .*[1-9]'
  $_ASSERT_TRUE_ '"expected qemu-img version"' $?
}

test_includes_mingw() {
  do_work "$TARGET" env | grep -q mingw.sh
  $_ASSERT_TRUE_ '"expected mingw.sh"' $?
}

test_runs_qemu() {
  do_work "$TARGET" "\$QEMU --version" 2>&1 | grep -q 'QEMU .*[1-9]'
  $_ASSERT_TRUE_ '"expected QEMU version"' $?
}

test_defines_qemuflags() {
  do_work "$TARGET" env | grep -q "^QEMUFLAGS="
  $_ASSERT_TRUE_ '"expected QEMUFLAGS to be defined"' $?
}

# utilities for testing whether bad environment causes early failure

# $1: emulated $0 argument; must export SHOULD_NOT_EXIST
try_to_do_work_along_with_a_command_expected_not_to_be_run() {
  # We want commands to be expanded by `sh -c` that do_work calls, not earlier
  # shellcheck disable=SC2016
  do_work "$1" 'set -u; touch "$SHOULD_NOT_EXIST"'
}

assert_output_includes() {
  haystack=$1
  needle=$2

  case $haystack in
    *$needle*) :;;
    *) false;;
  esac
  # shellcheck disable=SC2016 # shUnit2 asks quoting twice
  $_ASSERT_TRUE_ '"expected the output to include [$needle],
but was [$haystack]"' $?
}

# $1: exit status of do_work, $2: output, $3: expected error message
# SHOULD_NOT_EXIST must be defined
assert_fails_early() {
  # shellcheck disable=SC2034 # used indirectly a few lines below
  status=$1
  # shellcheck disable=SC2016 # shUnit2 asks to quote twice
  $_ASSERT_FALSE_ '"expected to fail"' '"$status"'

  assert_output_includes "$2" "$3"

  [ -f "$SHOULD_NOT_EXIST" ]
  $_ASSERT_FALSE_ '"expected not to run the command"' $?
}

# $1: bad prog value to be tested, $2: unique token
assert_bad_prog_value_causes_early_failure() {
  SHOULD_NOT_EXIST=${SHUNIT_TMPDIR}/$2
  export SHOULD_NOT_EXIST

  output=`try_to_do_work_along_with_a_command_expected_not_to_be_run "$1" 2>&1`
  assert_fails_early $? "$output" "cannot find mingw.sh"

  unset SHOULD_NOT_EXIST
}

# 2 test cases for bad prog values

test_fails_early_if_prog_value_is_unexpected() {
  assert_bad_prog_value_causes_early_failure some/unknown/path.sh tfeipviu
}

test_fails_early_if_cannot_read_mingw_sh() {
  bad_prog=unknown-parent/has-a-child/myqemu/myqemu.sh
  assert_bad_prog_value_causes_early_failure "$bad_prog" tfeicrms
}

try_to_do_work_with_bad_qemu_base() {
  QEMU_BASE="$1"
  try_to_do_work_along_with_a_command_expected_not_to_be_run "$TARGET"
}

# $1: bad QEMU_BASE to be tested, $2: unique token
assert_rejects_qemu_base() {
  SHOULD_NOT_EXIST=${SHUNIT_TMPDIR}/$2
  export SHOULD_NOT_EXIST

  output=`try_to_do_work_with_bad_qemu_base "$1" 2>&1`
  assert_fails_early $? "$output" reject

  unset SHOULD_NOT_EXIST
}

# 4 test cases for bad QEMU_BASE values

test_rejects_qemu_base_including_space() {
  assert_rejects_qemu_base "/path/includeing space/char" trqbis
}

test_rejects_bad_qemu_base() {
  assert_rejects_qemu_base "/bad/path/including
/newline" trbqb
}

test_rejects_qemu_base_if_it_begins_with_exactly_two_slashes() {
  assert_rejects_qemu_base //exactly/two/slashes trqbiibwets
}

test_rejects_qemu_base_lacking_executables() {
  assert_rejects_qemu_base /somewhere/do-not/have/binaries trqble
}

# unit test of accept_only_simple_path

test_accept_only_simple_path_succeeds() {
  accept_only_simple_path ../from/somewhere/to/simple variable_name
  $_ASSERT_TRUE_ '"expected accept_only_simple_path succeeds"' $?
}

assert_accept_only_simple_path_rejects() {
  target=$1
  prog=myqemu.sh
  output=`accept_only_simple_path "$target" variable_name 2>&1`
  # shellcheck disable=SC2016 #shUnit2 asks to quote twice
  $_ASSERT_FALSE_ '"expected accept_only_simple_path to reject [$target]"' $?
  unset prog

  assert_output_includes "$output" reject
}

test_accept_only_simple_path_rejects_newline() {
  assert_accept_only_simple_path_rejects "/newline/to/hide
/etc/passwd"
}

test_accept_only_simple_path_rejects_too_long_pathname() {
  assert_accept_only_simple_path_rejects "/long-`printf %097d 1`"
}

# shUnit2 setup

oneTimeSetUp() {
  dont_run_actually=y
  # load include to test
  # shellcheck source=myqemu.sh # the path, with trickiness removed
  . "$TARGET"
}

# load and run shUnit2
# shellcheck source=/dev/null # the other project has their policy
. "${SHUNIT2?}/shunit2"
