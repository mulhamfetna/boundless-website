#!/usr/bin/env bash
# Minimal assertion helpers. Each case script sources this, runs assertions,
# and ends with `finish`, which exits with the count of failures.
ASSERT_FAILURES=0
ASSERT_TOTAL=0

_assert_pass() {
  ASSERT_TOTAL=$((ASSERT_TOTAL + 1))
  printf '  \033[32m✓\033[0m %s\n' "$1"
}

_assert_fail() {
  ASSERT_TOTAL=$((ASSERT_TOTAL + 1))
  ASSERT_FAILURES=$((ASSERT_FAILURES + 1))
  printf '  \033[31m✗\033[0m %s\n' "$1"
  printf '      %s\n' "$2"
}

assert_equals() {
  local name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    _assert_pass "$name"
  else
    _assert_fail "$name" "expected [$expected] but got [$actual]"
  fi
}

assert_exit_code() {
  local name="$1" expected="$2"; shift 2
  "$@" >/dev/null 2>&1
  local actual=$?
  if [ "$expected" -eq "$actual" ]; then
    _assert_pass "$name"
  else
    _assert_fail "$name" "expected exit $expected but got $actual from: $*"
  fi
}

assert_file_exists() {
  local name="$1" path="$2"
  if [ -f "$path" ]; then
    _assert_pass "$name"
  else
    _assert_fail "$name" "file not found: $path"
  fi
}

assert_file_contains() {
  local name="$1" path="$2" needle="$3"
  if [ ! -f "$path" ]; then
    _assert_fail "$name" "file not found: $path"
  elif grep -qF -- "$needle" "$path"; then
    _assert_pass "$name"
  else
    _assert_fail "$name" "[$needle] not found in $path"
  fi
}

assert_file_not_contains() {
  local name="$1" path="$2" needle="$3"
  if [ ! -f "$path" ]; then
    _assert_fail "$name" "file not found: $path"
  elif grep -qF -- "$needle" "$path"; then
    _assert_fail "$name" "[$needle] unexpectedly present in $path"
  else
    _assert_pass "$name"
  fi
}

finish() {
  printf '  %d assertion(s), %d failure(s)\n' "$ASSERT_TOTAL" "$ASSERT_FAILURES"
  exit "$ASSERT_FAILURES"
}
