#!/usr/bin/env bash
set -euo pipefail

# Local Agentia quality gates (macOS / Linux).
# Edit this script to match your project. Agentia runs it from the repo root during
# `agentia cicd work test --local` and `agentia cicd work submit` (unless --skip-local-tests).
# The script must exit non-zero if any check fails.

echo "## Running Code Analyzer"
sf code-analyzer run

if [[ -n "${AGENTIA_APEX_TEST_CLASSES:-}" ]]; then
  # Normalize commas to spaces so --class-names gets discrete values
  # shellcheck disable=SC2206
  class_names=(${AGENTIA_APEX_TEST_CLASSES//,/ })
  if [[ ${#class_names[@]} -gt 0 ]]; then
    echo "## Running Apex tests: ${class_names[@]}"
    sf apex run test --class-names "${class_names[@]}" --result-format human --wait 10
  fi
fi

#echo "## Running LWC tests"
#npx sfdx-lwc-jest -- --passWithNoTests
