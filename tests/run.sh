#!/usr/bin/env bash
# Runs every case in tests/cases/ in filename order.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

failed_cases=0
for case_file in tests/cases/*.sh; do
  [ -f "$case_file" ] || continue
  printf '\n▸ %s\n' "$(basename "$case_file")"
  if ! bash "$case_file"; then
    failed_cases=$((failed_cases + 1))
  fi
done

printf '\n'
if [ "$failed_cases" -eq 0 ]; then
  printf '\033[32mAll test cases passed.\033[0m\n'
  exit 0
fi
printf '\033[31m%d test case(s) failed.\033[0m\n' "$failed_cases"
exit 1
