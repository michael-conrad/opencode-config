#!/usr/bin/env bash
set -euo pipefail

# RED test for P1-I2 (SC-12)
# Asserts Z3 contract generation section is ABSENT from plan-structure.md
# Expected: FAIL (section IS present before GREEN implementation)

TARGET_FILE=".opencode/skills/writing-plans/tasks/create/plan-structure.md"
PATTERN='Z3 Contract Generation'

if grep -q "$PATTERN" "$TARGET_FILE"; then
  echo "FAIL: Z3 contract generation section found in $TARGET_FILE (expected absent)"
  echo "Match at line: $(grep -n "$PATTERN" "$TARGET_FILE")"
  exit 1
else
  echo "PASS: Z3 contract generation section absent from $TARGET_FILE"
  exit 0
fi
